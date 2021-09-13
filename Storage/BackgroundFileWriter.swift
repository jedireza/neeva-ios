// Copyright Neeva. All rights reserved.

import Foundation
import Shared
import UIKit

private let log = Logger.storage

private class WriteDataTask {
    private var data: Data
    private let writer: (Data) -> Void
    private let lock = NSLock()
    private var pending = true

    var taskId: UIBackgroundTaskIdentifier?

    init(data: Data, writer: @escaping (Data) -> Void) {
        self.data = data
        self.writer = writer
    }

    func tryUpdateData(_ newData: Data) -> Bool {
        lock.lock()
        defer { lock.unlock() }

        // If the data is unchanged, then there is nothing more to do
        // even if the task is not pending. This way we avoid writing
        // the same data to the same file redundantly.
        if data == newData {
            return true
        }

        // If the task is not pending, then this task cannot be updated,
        // and a new task will need to be created.
        if !pending {
            return false
        }

        data = newData
        return true
    }

    func finish() {
        guard shouldWrite() else { return }

        writer(data)

        if let taskId = taskId {
            UIApplication.shared.endBackgroundTask(taskId)
            self.taskId = nil
        }
    }

    private func shouldWrite() -> Bool {
        lock.lock()
        defer { lock.unlock() }

        if !pending {
            return false
        }

        pending = false
        return true
    }
}

open class BackgroundFileWriter {
    private let serialQueue: DispatchQueue
    private let label: String
    private let path: String
    private var currentTask: WriteDataTask?

    public init(label: String, path: String) {
        self.label = label
        self.path = path
        serialQueue = DispatchQueue(label: "\(label):background-write-queue")
    }

    public func writeData(data: Data) {
        // First, we try to piggyback onto any existing write. That way we avoid writing old
        // data when new data has been provided.
        if let currentTask = currentTask, currentTask.tryUpdateData(data) {
            return
        }

        // At this point, any previous `pendingTask` can be abandoned since it is done or
        // just finishing up. We have to create a new task. The new task will be scheduled
        // behind any existing one, via `serialQueue`, so we can know that any existing one
        // will be done touching the file by the time this new task runs.

        let task = WriteDataTask(data: data, writer: writeDataSynchronously(data:))
        currentTask = task

        // Next we setup the background task. This call notifies the OS that we are going to
        // be doing work in the background. If it calls our `expirationHandler`, then we just
        // need to do the work right away.

        task.taskId = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            self.serialQueue.sync {
                task.finish()
            }
        })

        serialQueue.async {
            task.finish()
        }
    }

    private func writeDataSynchronously(data: Data) {
        do {
            try data.write(to: URL(fileURLWithPath: path), options: .atomic)
            log.info("\(label) data succesfully saved")
        } catch {
            log.error("\(label) data failed to save: \(error.localizedDescription)")
        }
    }
}

#if DEBUG  // Exposed for testing
    extension BackgroundFileWriter {
        public var serialQueueForTesting: DispatchQueue {
            serialQueue
        }
    }
#endif

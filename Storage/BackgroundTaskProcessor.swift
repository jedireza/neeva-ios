// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared
import UIKit

private let log = Logger.storage

public protocol Task {
    func isDuplicate(of: Task) -> Bool
    func run()
}

private class BackgroundTask {
    private var task: Task
    private let lock = NSLock()
    private var pending = true

    var taskId: UIBackgroundTaskIdentifier?

    init(for task: Task) {
        self.task = task
    }

    func tryUpdateTask(_ newTask: Task) -> Bool {
        lock.lock()
        defer { lock.unlock() }

        // If the new task is a duplicate, then there is nothing more to do
        // even if the current task is not pending. This way we avoid repeating
        // the same work.
        if newTask.isDuplicate(of: task) {
            return true
        }

        // If the task is not pending, then this task cannot be updated,
        // and a new task will need to be created.
        if !pending {
            return false
        }

        task = newTask
        return true
    }

    func finish() {
        guard shouldRun() else { return }

        task.run()

        if let taskId = taskId {
            UIApplication.shared.endBackgroundTask(taskId)
            self.taskId = nil
        }
    }

    private func shouldRun() -> Bool {
        lock.lock()
        defer { lock.unlock() }

        if !pending {
            return false
        }

        pending = false
        return true
    }
}

open class BackgroundTaskProcessor {
    private var currentBgTask: BackgroundTask?

    let label: String
    let serialQueue: DispatchQueue

    public init(label: String) {
        self.label = label
        serialQueue = DispatchQueue(label: "\(label):background-task-queue")
    }

    public func performTask(task: Task) {
        // First, we try to piggyback onto any existing task. That way we avoid doing
        // possibly out-dated work.
        if let currentBgTask = currentBgTask, currentBgTask.tryUpdateTask(task) {
            return
        }

        // At this point, any previous `backgroundTask` can be abandoned since it is done or
        // just finishing up. We have to create a new task. The new task will be scheduled
        // behind any existing one, via `serialQueue`, so we can know that any existing one
        // will be done touching the file by the time this new task runs.

        let backgroundTask = BackgroundTask(for: task)
        currentBgTask = backgroundTask

        // Next we setup the background task. This call notifies the OS that we are going to
        // be doing work in the background. If it calls our `expirationHandler`, then we just
        // need to do the work right away.

        backgroundTask.taskId = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            self.serialQueue.sync {
                backgroundTask.finish()
            }
        })

        serialQueue.async {
            backgroundTask.finish()
        }
    }

    public func performTask(closure: @escaping () -> Void) {
        class Adapter: Task {
            let closure: () -> Void
            init(closure: @escaping () -> Void) { self.closure = closure }
            public func isDuplicate(of: Task) -> Bool { false }
            public func run() { closure() }
        }
        performTask(task: Adapter(closure: closure))
    }
}

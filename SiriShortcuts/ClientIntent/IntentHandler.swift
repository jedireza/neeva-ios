// Copyright Neeva. All rights reserved.

import Intents

class IntentHandler: INExtension {
    override func handler(for intent: INIntent) -> Any {
        switch intent {
        case is OpenURLIntent:
            return OpenURLIntentHandler()
        case is SearchNeevaIntent:
            return SearchNeevaIntentHandler()
        default:
            return self
        }
    }
}

class OpenURLIntentHandler: NSObject, OpenURLIntentHandling {
    func handle(intent: OpenURLIntent, completion: @escaping (OpenURLIntentResponse) -> Void) {
        completion(OpenURLIntentResponse(code: .continueInApp, userActivity: nil))
    }
}

class SearchNeevaIntentHandler: NSObject, SearchNeevaIntentHandling {
    func resolveText(for intent: SearchNeevaIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        if let query = intent.text {
            completion(.success(with: query))
        } else {
            completion(INStringResolutionResult.needsValue())
        }
    }

    func handle(intent: SearchNeevaIntent, completion: @escaping (SearchNeevaIntentResponse) -> Void) {
        completion(SearchNeevaIntentResponse(code: .continueInApp, userActivity: nil))
    }
}

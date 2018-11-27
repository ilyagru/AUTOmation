//
//  GoToWorkIntentHandler.swift
//  GoToWorkIntent
//
//  Created by Ilya Gruzhevski on 23/11/2018.
//  Copyright © 2018 Ilya Gruzhevski. All rights reserved.
//

import Foundation
import AutoAPI
import HMKit

final class GoToWorkIntentHandler: NSObject, GoToWorkIntentHandling {

    private let commandService = CommandService(operationQueue: OperationQueue())

    // Required method to implement
    func handle(intent: GoToWorkIntent, completion: @escaping (GoToWorkIntentResponse) -> Void) {
        // Turn on everything in the car
        commandService.sendGoToWorkCommands { result in
            switch result {
            case .failure(let error):
                print("INTENT FAILURE", error)
                completion(GoToWorkIntentResponse(code: .failure, userActivity: nil))
            case .success:
                print("INTENT SUCCESS")
                completion(GoToWorkIntentResponse(code: .success, userActivity: nil))
            }
        }
    }

    // Optional method to confirm if the intent is ready to be handled
    func confirm(intent: GoToWorkIntent, completion: @escaping (GoToWorkIntentResponse) -> Void) {
        commandService.setup(for: nil) { (serial) in
            if let _ = serial {
                completion(GoToWorkIntentResponse(code: .ready, userActivity: nil))
                print("READY")
            } else {
                print("NOT AVAILABLE, try to setup it")
                completion(GoToWorkIntentResponse(code: .failureNotAvailable, userActivity: nil))
            }
        }
    }

}

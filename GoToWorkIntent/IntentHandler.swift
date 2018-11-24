//
//  IntentHandler.swift
//  GoToWorkIntent
//
//  Created by Ilya Gruzhevski on 23/11/2018.
//  Copyright © 2018 Ilya Gruzhevski. All rights reserved.
//

import Intents

final class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        guard intent is GoToWorkIntent else {
            fatalError("Unhandled intent type: \(intent)")
        }

        return GoToWorkIntentHandler()
    }
    
}

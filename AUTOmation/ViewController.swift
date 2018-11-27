//
//  ViewController.swift
//  AUTOmation
//
//  Created by Ilya Gruzhevski on 23/11/2018.
//  Copyright © 2018 Ilya Gruzhevski. All rights reserved.
//

import UIKit
import Intents
import AutoAPI
import HMKit
import os.log

final class ViewController: UIViewController {

    private let commandService = CommandService(operationQueue: OperationQueue())

    // MARK: - Overrides

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // To save downloaded certificates and the serial
        commandService.setup(for: nil) { (serial) in
            if let serial = serial {
                print("SETUP SUCCESS", serial)
            } else {
                print("SETUP FAILURE")
            }
        }

        // Setting up the intent for the first time
        donateInteraction()
    }

    // MARK: - Actions

    @IBAction func reverseIntent(_ sender: UIButton) {
        // Turn off everything in the car
        commandService.reverseSendGoToWorkCommands { result in
            switch result {
            case .failure(let error):
                print("REVERSE FAILURE", error)
            case .success:
                print("REVERSE SUCCESS")
            }
        }
    }

    // MARK: - Helpers

    private func donateInteraction() {
        let intent = GoToWorkIntent()
        intent.suggestedInvocationPhrase = "I'm going to work"

        let interaction = INInteraction(intent: intent, response: nil)

        interaction.donate { (error) in
            if error != nil {
                if let error = error as NSError? {
                    os_log("Interaction donation failed: %@", log: OSLog.default, type: .error, error)
                } else {
                    os_log("Successfully donated interaction")
                }
            }
        }
    }

}


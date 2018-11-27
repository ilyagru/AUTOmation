//
//  CommandService.swift
//  AUTOmation
//
//  Created by Ilya Gruzhevski on 23/11/2018.
//  Copyright © 2018 Ilya Gruzhevski. All rights reserved.
//

import Foundation
import HMKit
import AutoAPI

final class CommandService {

    enum CommandResult {
        case failure(String)
        case success
    }

    let operationQueue: OperationQueue

    init(operationQueue: OperationQueue) {
        self.operationQueue = operationQueue
    }

    // MARK: - Commands

    func setup(for delegate: (HMLocalDeviceDelegate & HMLinkDelegate)?, completion: @escaping (Data?) -> Void) {
        // Logging options that are interesting to you
        HMLocalDevice.loggingOptions = [.bluetooth, .telematics]

        /*
         * Before using HMKit, you'll have to initialise the LocalDevice singleton
         * with a snippet from the Platform Workspace:
         *
         *   1. Sign in to the workspace
         *   2. Go to the LEARN section and choose iOS
         *   3. Follow the Getting Started instructions
         *
         * By the end of the tutorial you will have a snippet for initialisation
         * looking something like this:
         */

        do {
            try HMLocalDevice.shared.initialise(deviceCertificate: Constants.deviceCertificate, devicePrivateKey: Constants.devicePrivateKey, issuerPublicKey: Constants.issuerPublicKey)
        } catch {
            print("Invalid initialisation parameters, please double check the snippet – error:", error)
            completion(nil)
        }

        HMLocalDevice.shared.delegate = delegate

        guard Persistence.shared.serial == nil else {
            return completion(Persistence.shared.serial)
        }

        do {
            // Send a command to the car through Telematics.
            // Make sure that the emulator is OPENED for this to work,
            // otherwise "Vehicle asleep" could be returned.
            try HMTelematics.downloadAccessCertificate(accessToken: Constants.accessToken) { result in
                if case HMTelematicsRequestResult.success(let serial) = result {
                    Persistence.shared.serial = serial
                    completion(serial)
                } else {
                    completion(nil)
                    print("Failed to download certificate \(result).")
                }
            }
        } catch {
            print("Download cert error: \(error)")
            completion(nil)
        }
    }

    func sendGoToWorkCommands(completion: @escaping (CommandResult) -> Void) {
        // Commands to send
        let engine = AAEngine.turnIgnitionOnOff(.active)
        let doorUnlock = AADoorLocks.lockUnlock(.unlocked)
        let lights = AALights.controlLights(frontExterior: AAFrontLightState.active, rearExterior: AAActiveState.active, interior: nil, ambientColour: nil)!
        let destinationCoordinates = AACoordinates(latitude: 52.5052372, longitude: 13.3909849)
        let directions = AANaviDestination.setDestination(coordinate: destinationCoordinates, name: "Office")
        let screen = AAGraphics.displayImage(URL(string: "https://media.idownloadblog.com/wp-content/uploads/2014/04/ipad-calendar-list-view.png")!)
        let climate = AAClimate.changeTemperatures(driver: 22, passenger: 22, rear: 20)

        operationQueue.addOperation { [weak self] in
            self?.sendCommand(doorUnlock, completion: { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
        operationQueue.addOperation { [weak self] in
            self?.sendCommand(engine, completion: { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
        operationQueue.addOperation { [weak self] in
            self?.sendCommand(lights, completion: { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
        operationQueue.addOperation { [weak self] in
            self?.sendCommand(climate, completion: { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
        let directionsOperation = Operation()
        directionsOperation.completionBlock = { [weak self] in
            self?.sendCommand(directions, completion: { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
        let screenOperation = Operation()
        screenOperation.completionBlock = { [weak self] in
            self?.sendCommand(screen, completion: { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
        // It seems that the image will not be shown if a destination is set later
        // Updating screen after setting up navigation
        screenOperation.addDependency(directionsOperation)
        operationQueue.addOperation(directionsOperation)
        operationQueue.addOperation(screenOperation)

        operationQueue.waitUntilAllOperationsAreFinished()
        completion(.success)
    }

    func reverseSendGoToWorkCommands(completion: @escaping (CommandResult) -> Void) {
        // Commands to send
        let engine = AAEngine.turnIgnitionOnOff(.inactive)
        let doorUnlock = AADoorLocks.lockUnlock(.locked)
        let lights = AALights.controlLights(frontExterior: .inactive, rearExterior: .inactive, interior: nil, ambientColour: nil)!
        let destinationCoordinates = AACoordinates(latitude: 0.0, longitude: 0.0)
        let directions = AANaviDestination.setDestination(coordinate: destinationCoordinates, name: "")
        let screen = AAGraphics.displayImage(URL(string: "https://mobilityhack.splashthat.com")!)
        let climate = AAClimate.changeTemperatures(driver: 0, passenger: 0, rear: 0)

        operationQueue.addOperation { [weak self] in
            self?.sendCommand(engine, completion: { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
        operationQueue.addOperation { [weak self] in
            self?.sendCommand(doorUnlock, completion: { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
        operationQueue.addOperation { [weak self] in
            self?.sendCommand(lights, completion: { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
        operationQueue.addOperation { [weak self] in
            self?.sendCommand(directions, completion: { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
        operationQueue.addOperation { [weak self] in
            self?.sendCommand(screen, completion: { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
        operationQueue.addOperation { [weak self] in
            self?.sendCommand(climate, completion: { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }

        operationQueue.waitUntilAllOperationsAreFinished()
        completion(.success)
    }

    // MARK: - Helpers

    private func sendCommand(_ command: [UInt8], completion: @escaping (CommandResult) -> Void) {
        guard let serial = Persistence.shared.serial else { return }

        do {
            try HMTelematics.sendCommand(command, serial: serial, completionHandler: { response in
                switch response {
                case .failure(let error):
                    print("COMMAND FAILURE")
                    completion(.failure("Failed to send a concrete command \(error)."))
                case .success(let data):
                    print("COMMAND SUCCESS")
                    guard let _ = data else {
                        return completion(.failure("Missing response data"))
                    }

                    completion(.success)
                }
            })
        } catch {
            print("Failed to send command", error)
        }
    }

}

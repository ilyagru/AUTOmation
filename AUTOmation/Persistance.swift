//
//  Persistance.swift
//  AUTOmation
//
//  Created by Ilya Gruzhevski on 23/11/2018.
//  Copyright © 2018 Ilya Gruzhevski. All rights reserved.
//

import Foundation

final class Persistence {

    static let shared = Persistence(defaults: UserDefaults(suiteName: Constants.groupId))

    var serial: Data? {
        get {
            return defaults?.data(forKey: "vehicle-serial")
        }
        set {
            defaults?.set(newValue, forKey: "vehicle-serial")
            defaults?.synchronize()
        }
    }

    private let defaults: UserDefaults?

    init(defaults: UserDefaults?) {
        self.defaults = defaults
    }

    // MARK: - Helpers

    func removeSerial() {
        defaults?.removeObject(forKey: "vehicle-serial")
    }

}

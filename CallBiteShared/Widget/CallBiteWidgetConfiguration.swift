//
//  CallBiteWidgetConfiguration.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 13/09/26.
//

import Foundation

enum CallBiteWidgetConfiguration {
    static let kind = "CallBiteNutritionWidget"
    static let appGroupInfoKey = "CallBiteAppGroupIdentifier"

    static func appGroupIdentifier(in bundle: Bundle = .main) -> String? {
        guard let identifier = bundle.object(forInfoDictionaryKey: appGroupInfoKey) as? String,
              !identifier.isEmpty else {
            return nil
        }

        return identifier
    }
}

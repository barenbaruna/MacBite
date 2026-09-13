//
//  CallBiteWidgetSnapshotStore.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 13/09/26.
//

import Foundation

struct CallBiteWidgetSnapshotStore {
    private static let snapshotKey = "callbite.widget.todayNutrition"

    private let defaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        defaults: UserDefaults,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.defaults = defaults
        self.encoder = encoder
        self.decoder = decoder
    }

    static func makeDefault(bundle: Bundle = .main) -> Self? {
        guard let identifier = CallBiteWidgetConfiguration.appGroupIdentifier(in: bundle),
              let defaults = UserDefaults(suiteName: identifier) else {
            return nil
        }

        return CallBiteWidgetSnapshotStore(defaults: defaults)
    }

    func load() -> CallBiteWidgetSnapshot? {
        guard let data = defaults.data(forKey: Self.snapshotKey) else { return nil }
        return try? decoder.decode(CallBiteWidgetSnapshot.self, from: data)
    }

    func save(_ snapshot: CallBiteWidgetSnapshot) throws {
        defaults.set(try encoder.encode(snapshot), forKey: Self.snapshotKey)
    }
}

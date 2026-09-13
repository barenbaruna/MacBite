//
//  CallBiteWidgetAction.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 13/09/26.
//

import Foundation

enum CallBiteWidgetAction: String, Sendable {
    case camera
    case manual

    private static let scheme = "callbite"
    private static let host = "log"

    var url: URL {
        var components = URLComponents()
        components.scheme = Self.scheme
        components.host = Self.host
        components.path = "/\(rawValue)"

        guard let url = components.url else {
            preconditionFailure("Unable to construct the CallBite widget deep link.")
        }

        return url
    }

    init?(url: URL) {
        guard url.scheme == Self.scheme, url.host == Self.host else { return nil }
        let actionName = String(url.path.drop(while: { $0 == "/" }))
        self.init(rawValue: actionName)
    }
}

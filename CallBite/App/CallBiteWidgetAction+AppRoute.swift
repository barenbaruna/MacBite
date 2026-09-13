//
//  CallBiteWidgetAction+AppRoute.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 13/09/26.
//

extension CallBiteWidgetAction {
    var appRoute: AppRoute {
        switch self {
        case .camera:
            .foodCapture
        case .manual:
            .manualLogging
        }
    }
}

//
//  AppRoute.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import Foundation

enum AppRoute: Hashable, Identifiable {
    case dashboard
    case foodCapture
    case manualLogging

    var id: Self { self }
}

//
//  AppContainer.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import Combine
import Foundation

/// Dependency container utama aplikasi CallBite
@MainActor
final class AppContainer: ObservableObject {
    @Published var activeRoute: AppRoute = .dashboard

    init() {}
}

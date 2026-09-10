//
//  DashboardViewModel.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import Combine
import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published private(set) var isShowingLoggingOptions = false

    func toggleLoggingOptions() {
        isShowingLoggingOptions.toggle()
    }

    func hideLoggingOptions() {
        isShowingLoggingOptions = false
    }
}

//
//  LoggingDestinationView.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 09/09/26.
//

import SwiftUI

struct LoggingDestinationView: View {
    let route: AppRoute
    let onDismiss: () -> Void

    @ViewBuilder
    var body: some View {
        switch route {
        case .dashboard:
            DashboardFactory.makeView()
        case .foodCapture:
            FoodCaptureFactory.makeView(onDismiss: onDismiss)
        case .manualLogging:
            ManualLoggingFactory.makeView(onDismiss: onDismiss)
        }
    }
}

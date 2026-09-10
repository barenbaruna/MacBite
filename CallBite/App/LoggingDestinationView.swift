//
//  LoggingDestinationView.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 09/09/26.
//

import SwiftUI
import UIKit

struct LoggingDestinationView: View {
    let route: AppRoute
    let onDismiss: () -> Void
    var onUsePhoto: ((UIImage) -> Void)?
    var onCalculate: ((String, [ManualIngredientInput]) -> Void)?

    @ViewBuilder
    var body: some View {
        switch route {
        case .dashboard:
            DashboardFactory.makeView()
        case .foodCapture:
            FoodCaptureFactory.makeView(
                onDismiss: onDismiss,
                onUsePhoto: { image in
                    onUsePhoto?(image)
                }
            )
        case .manualLogging:
            ManualLoggingFactory.makeView(
                onDismiss: onDismiss,
                onCalculate: { foodName, ingredients in
                    onCalculate?(foodName, ingredients)
                }
            )
        }
    }
}

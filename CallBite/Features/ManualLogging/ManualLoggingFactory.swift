//
//  ManualLoggingFactory.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 01/09/26.
//

import SwiftUI

enum ManualLoggingFactory {
    @MainActor
    static func makeView(
        onDismiss: @escaping () -> Void = {},
        onCalculate: @escaping (String, [ManualIngredientInput]) -> Void = { _, _ in }
    ) -> some View {
        let viewModel = ManualLoggingViewModel()

        return ManualLoggingView(
            viewModel: viewModel,
            onDismiss: onDismiss,
            onCalculate: onCalculate
        )
    }
}

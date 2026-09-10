//
//  GoalsFactory.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI

/// Factory for constructing the Goals module.
enum GoalsFactory {
    @MainActor
    static func makeView() -> some View {
        WeightGoalView()
    }
}

//
//  CallBiteApp.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 31/08/26.
//

import SwiftUI

@main
struct CallBiteApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView(onResetOnboarding: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        hasCompletedOnboarding = false
                    }
                })
            } else {
                OnboardingFactory.makeView(onFinish: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        hasCompletedOnboarding = true
                    }
                })
            }
        }
    }
}

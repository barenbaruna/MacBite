//
//  DashboardToolbarContent.swift
//  CallBite
//
//  Created by Codex on 11/09/26.
//

import SwiftUI

struct DashboardToolbarContent: ToolbarContent {
    let isShowingToday: Bool
    let onReturnToToday: () -> Void
    let onCalendarSelected: () -> Void
    let onProfileSelected: () -> Void

    var body: some ToolbarContent {
        if !isShowingToday {
            ToolbarItem(placement: .topBarLeading) {
                Button("Today", action: onReturnToToday)
                    .accessibilityLabel("Return to Today's Dashboard")
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button("Open Calendar", systemImage: "calendar", action: onCalendarSelected)
                .labelStyle(.iconOnly)
        }

        ToolbarSpacer(.fixed, placement: .topBarTrailing)

        ToolbarItem(placement: .topBarTrailing) {
            Button(action: onProfileSelected) {
                Image(systemName: "person.fill")
                    .foregroundStyle(AppColor.gainWeight)
                    .accessibilityHidden(true)
            }
            .buttonStyle(.glassProminent)
            .buttonBorderShape(.circle)
            .tint(AppColor.white)
            .accessibilityLabel("Profile and Target Weight")
        }
    }
}

#Preview {
    NavigationStack {
        AppColor.backgroundPrimary
            .navigationTitle("Today, 4 Sep 2026")
            .toolbar {
                DashboardToolbarContent(
                    isShowingToday: true,
                    onReturnToToday: {},
                    onCalendarSelected: {},
                    onProfileSelected: {}
                )
            }
    }
    .preferredColorScheme(.dark)
}

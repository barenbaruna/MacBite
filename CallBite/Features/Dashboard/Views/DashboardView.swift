//
//  DashboardView.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI

/// Tampilan utama Dashboard progres nutrisi harian
struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                CalorieProgressView(summary: viewModel.summary)
                Spacer()
            }
            .padding()
            .navigationTitle("Dashboard")
        }
    }
}

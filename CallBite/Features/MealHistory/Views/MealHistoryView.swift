//
//  MealHistoryView.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 01/09/26.
//

import SwiftUI

/// Tampilan riwayat makanan yang telah dicatat
struct MealHistoryView: View {
    @ObservedObject var viewModel: MealHistoryViewModel

    var body: some View {
        NavigationStack {
            List(viewModel.entries) { entry in
                Text(entry.name)
            }
            .navigationTitle("History")
        }
    }
}

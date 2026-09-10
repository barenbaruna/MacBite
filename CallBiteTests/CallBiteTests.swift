//
//  CallBiteTests.swift
//  CallBiteTests
//
//  Created by Baren Baruna Harahap on 31/08/26.
//

import Testing
@testable import CallBite

@Suite("DashboardViewModel Tests")
struct DashboardViewModelTests {
    @Test("Membuka dan menutup pilihan pencatatan makanan")
    @MainActor
    func togglesLoggingOptions() {
        // Given
        let viewModel = DashboardViewModel()

        // When
        viewModel.toggleLoggingOptions()

        // Then
        #expect(viewModel.isShowingLoggingOptions)

        // When
        viewModel.hideLoggingOptions()

        // Then
        #expect(!viewModel.isShowingLoggingOptions)
    }
}

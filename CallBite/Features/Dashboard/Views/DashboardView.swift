//
//  DashboardView.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI

/// Tampilan utama Dashboard progres nutrisi harian
struct DashboardView: View {
    @ObservedObject private var viewModel: DashboardViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var presentedFullScreenRoute: AppRoute?
    @State private var presentedSheetRoute: AppRoute?

    init(viewModel: DashboardViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            AppColor.backgroundPrimary
                .ignoresSafeArea()

            if viewModel.isShowingLoggingOptions {
                LoggingOptionsOverlay(
                    onCameraSelected: showCamera,
                    onManualInputSelected: showManualInput
                )
                .transition(loggingOptionsTransition)
            }

            loggingButton
                .padding(.trailing, AppSpacing.large)
                .padding(.bottom, AppSpacing.large)
        }
        .fullScreenCover(item: $presentedFullScreenRoute) { route in
            LoggingDestinationView(route: route) {
                presentedFullScreenRoute = nil
            }
        }
        .sheet(item: $presentedSheetRoute) { route in
            LoggingDestinationView(route: route) {
                presentedSheetRoute = nil
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(AppColor.dark950)
        }
    }

    private var loggingButton: some View {
        Button(
            viewModel.isShowingLoggingOptions ? "Tutup Pilihan Pencatatan" : "Catat Makanan",
            systemImage: viewModel.isShowingLoggingOptions ? "xmark" : "plus",
            action: toggleLoggingOptions
        )
        .font(AppTypography.title1)
        .labelStyle(.iconOnly)
        .buttonStyle(.glassProminent)
        .controlSize(.extraLarge)
        .tint(AppColor.floatingAction)
        .contentTransition(.symbolEffect(.replace))
    }

    private var loggingOptionsTransition: AnyTransition {
        reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .bottom))
    }

    private var loggingAnimation: Animation {
        reduceMotion ? AppAnimation.reducedMotion : AppAnimation.smooth
    }

    private func toggleLoggingOptions() {
        AppHaptics.primaryAction()
        withAnimation(loggingAnimation) {
            viewModel.toggleLoggingOptions()
        }
    }

    private func showCamera() {
        prepareForPresentation()
        presentedFullScreenRoute = .foodCapture
    }

    private func showManualInput() {
        prepareForPresentation()
        presentedSheetRoute = .manualLogging
    }

    private func prepareForPresentation() {
        AppHaptics.selectionChanged()
        viewModel.hideLoggingOptions()
    }
}

#Preview {
    DashboardFactory.makeView()
}

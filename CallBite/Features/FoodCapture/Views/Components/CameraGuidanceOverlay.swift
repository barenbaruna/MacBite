//
//  CameraGuidanceOverlay.swift
//  CallBite
//
//  Created by Codex on 12/09/26.
//

import SwiftUI

struct CameraGuidanceOverlay: View {
    let layout: CameraGuidanceLayout
    let guidance: CameraPositionGuidance
    let checks: CameraQualityChecks

    var body: some View {
        ZStack(alignment: .topLeading) {
            CameraSafeAreaView()
            .frame(width: layout.guideFrame.width, height: layout.guideFrame.height)
            .position(
                x: layout.guideFrame.midX,
                y: layout.guideFrame.midY
            )

            CameraInstructionCard(guidance: guidance)
                .frame(
                    width: layout.instructionFrame.width,
                    height: layout.instructionFrame.height
                )
                .position(
                    x: layout.instructionFrame.midX,
                    y: layout.instructionFrame.midY
                )

            CameraQualityStatusView(checks: checks)
                .frame(
                    width: layout.statusFrame.width,
                    height: layout.statusFrame.height
                )
                .position(
                    x: layout.statusFrame.midX,
                    y: layout.statusFrame.midY
                )
        }
        .allowsHitTesting(false)
    }
}

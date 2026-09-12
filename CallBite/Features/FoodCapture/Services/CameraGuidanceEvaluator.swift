//
//  CameraGuidanceEvaluator.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 12/09/26.
//

import CoreGraphics

struct CameraPositionEvaluation: Equatable {
    let guidance: CameraPositionGuidance
    let isAcceptable: Bool
}

struct CameraGuidanceEvaluator {
    func evaluatePosition(
        analysis: CameraFrameAnalysis,
        viewportSize: CGSize,
        guideFrame: CGRect
    ) -> CameraPositionEvaluation {
        guard let subjectBounds = analysis.subjectBounds,
              analysis.portraitFrameWidth > 0,
              analysis.portraitFrameHeight > 0,
              viewportSize.width > 0,
              viewportSize.height > 0 else {
            return CameraPositionEvaluation(guidance: .placeMeal, isAcceptable: false)
        }

        let subjectFrame = convertToViewport(
            subjectBounds.normalizedRect,
            sourceSize: CGSize(
                width: analysis.portraitFrameWidth,
                height: analysis.portraitFrameHeight
            ),
            viewportSize: viewportSize
        )
        let visibleSubjectFrame = subjectFrame.intersection(
            CGRect(origin: .zero, size: viewportSize)
        )
        let coverage = visibleSubjectFrame.width * visibleSubjectFrame.height
            / (guideFrame.width * guideFrame.height)

        if coverage < CameraGuidanceThresholds.minimumSubjectCoverage {
            return CameraPositionEvaluation(guidance: .moveCloser, isAcceptable: false)
        }

        let touchesViewportEdge = subjectFrame.minX <= 0
            || subjectFrame.minY <= 0
            || subjectFrame.maxX >= viewportSize.width
            || subjectFrame.maxY >= viewportSize.height

        if coverage > CameraGuidanceThresholds.maximumSubjectCoverage || touchesViewportEdge {
            return CameraPositionEvaluation(guidance: .moveBack, isAcceptable: false)
        }

        let centerRegionInset = (1 - CameraGuidanceThresholds.centeredRegionFraction) / 2
        let centerRegion = guideFrame.insetBy(
            dx: guideFrame.width * centerRegionInset,
            dy: guideFrame.height * centerRegionInset
        )

        if !centerRegion.contains(subjectFrame.center) {
            return CameraPositionEvaluation(guidance: .centerPlate, isAcceptable: false)
        }

        if !guideFrame.contains(subjectFrame) {
            return CameraPositionEvaluation(guidance: .moveBack, isAcceptable: false)
        }

        return CameraPositionEvaluation(guidance: .ready, isAcceptable: true)
    }

    private func convertToViewport(
        _ normalizedRect: CGRect,
        sourceSize: CGSize,
        viewportSize: CGSize
    ) -> CGRect {
        let scale = max(
            viewportSize.width / sourceSize.width,
            viewportSize.height / sourceSize.height
        )
        let displayedSize = CGSize(
            width: sourceSize.width * scale,
            height: sourceSize.height * scale
        )
        let cropOffset = CGPoint(
            x: (displayedSize.width - viewportSize.width) / 2,
            y: (displayedSize.height - viewportSize.height) / 2
        )

        return CGRect(
            x: normalizedRect.minX * displayedSize.width - cropOffset.x,
            y: normalizedRect.minY * displayedSize.height - cropOffset.y,
            width: normalizedRect.width * displayedSize.width,
            height: normalizedRect.height * displayedSize.height
        )
    }
}

private extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}

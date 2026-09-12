//
//  CameraGuidanceEvaluatorTests.swift
//  CallBiteTests
//
//  Created by Codex on 12/09/26.
//

@testable import CallBite
import CoreGraphics
import Testing

@Suite("CameraGuidanceEvaluator Tests")
struct CameraGuidanceEvaluatorTests {
    private let evaluator = CameraGuidanceEvaluator()
    private let viewportSize = CGSize(width: 402, height: 896)
    private let guideFrame = CGRect(x: 40, y: 212, width: 323, height: 323)

    @Test("Small subject asks the user to move closer")
    func smallSubjectMovesCloser() {
        let result = evaluate(subjectFrame: CGRect(x: 151, y: 323, width: 100, height: 100))

        #expect(result.guidance == .moveCloser)
        #expect(!result.isAcceptable)
    }

    @Test("Oversized subject asks the user to move back")
    func oversizedSubjectMovesBack() {
        let result = evaluate(subjectFrame: CGRect(x: 45, y: 217, width: 310, height: 310))

        #expect(result.guidance == .moveBack)
        #expect(!result.isAcceptable)
    }

    @Test("Off-center subject asks the user to center the plate")
    func offCenterSubjectCentersPlate() {
        let result = evaluate(subjectFrame: CGRect(x: 41, y: 270, width: 200, height: 200))

        #expect(result.guidance == .centerPlate)
        #expect(!result.isAcceptable)
    }

    @Test("Centered subject with suitable coverage passes")
    func centeredSubjectPasses() {
        let result = evaluate(subjectFrame: CGRect(x: 91, y: 263, width: 220, height: 220))

        #expect(result.guidance == .ready)
        #expect(result.isAcceptable)
    }

    private func evaluate(subjectFrame: CGRect) -> CameraPositionEvaluation {
        evaluator.evaluatePosition(
            analysis: CameraFrameAnalysis(
                brightness: 0.50,
                subjectBounds: CameraSubjectBounds(
                    x: subjectFrame.minX / viewportSize.width,
                    y: subjectFrame.minY / viewportSize.height,
                    width: subjectFrame.width / viewportSize.width,
                    height: subjectFrame.height / viewportSize.height
                ),
                portraitFrameWidth: viewportSize.width,
                portraitFrameHeight: viewportSize.height
            ),
            viewportSize: viewportSize,
            guideFrame: guideFrame
        )
    }
}

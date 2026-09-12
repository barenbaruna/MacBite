//
//  CalorieOverlimitTests.swift
//  CallBiteTests
//
//  Created by Baren Baruna Harahap on 12/09/26.
//

@testable import CallBite
import CoreGraphics
import Foundation
import Testing

@Suite("CalorieOverlimitTests")
struct CalorieOverlimitTests {
    @Test func testOverlimitColorInterpolation() {
        let lapStart = AppColor.overlimitColor(at: 0.0)
        #expect(lapStart == AppColor.overlimitBaseRed)

        let nearBlackAt18 = AppColor.overlimitColor(at: 0.18)
        #expect(nearBlackAt18 == AppColor.overlimitNearBlack)

        let nearBlackBeyond = AppColor.overlimitColor(at: 0.50)
        #expect(nearBlackBeyond == AppColor.overlimitNearBlack)
    }

    @Test func testOverlimitProgressCalculation() {
        let view = CalorieProgressView(
            consumedCalories: 3000,
            targetCalories: 2500,
            ringProgress: 1.2
        )
        #expect(view.consumedCalories > view.targetCalories)
        #expect(view.ringProgress > 1.0)
    }
}

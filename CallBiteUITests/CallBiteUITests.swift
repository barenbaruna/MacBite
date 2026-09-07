//
//  CallBiteUITests.swift
//  CallBiteUITests
//
//  Created by Baren Baruna Harahap on 31/08/26.
//

import XCTest

final class CallBiteUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it's important to set the initial state - such as interface orientation -
        // required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testSaveFoodCompleteFlow() throws {
        let app = XCUIApplication()
        app.launch()

        let saveButton = app.buttons["Save Food"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))

        // Save screenshots to disk for visual verification
        let baseDir = "/Users/barenbaruna/.gemini/antigravity-ide/brain/ef144f10-1d22-488a-99da-9764902a2849"
        let scratchPath = "\(baseDir)/scratch"

        // 1. Initial State: Full Page Add Food
        let initialData = app.screenshot().pngRepresentation
        try? initialData.write(to: URL(fileURLWithPath: "\(scratchPath)/step1_full_page.png"))

        // 2. Tap Save Food -> Shrinks to Floating Rounded Card & Flips 3D
        saveButton.tap()
        Thread.sleep(forTimeInterval: 0.50)
        let flipData = app.screenshot().pngRepresentation
        try? flipData.write(to: URL(fileURLWithPath: "\(scratchPath)/step2_floating_rounded_card.png"))

        // 3. Morph & Orbit: Orb travels around circular ring with progress
        Thread.sleep(forTimeInterval: 1.70)
        let orbitData = app.screenshot().pngRepresentation
        try? orbitData.write(to: URL(fileURLWithPath: "\(scratchPath)/step3_orbiting_progress.png"))

        // 4. Settled State: Orb dissolved, ring filled, calories updated
        Thread.sleep(forTimeInterval: 1.50)
        let settledData = app.screenshot().pngRepresentation
        try? settledData.write(to: URL(fileURLWithPath: "\(scratchPath)/step4_settled_dashboard.png"))

        // 5. Tap Plus Button to re-open Add Food
        let plusButton = app.buttons["plus"]
        if plusButton.waitForExistence(timeout: 5) {
            plusButton.tap()
            Thread.sleep(forTimeInterval: 0.5)
            let reopenData = app.screenshot().pngRepresentation
            try? reopenData.write(to: URL(fileURLWithPath: "\(scratchPath)/step5_reopened_full_page.png"))
        }
    }

    @MainActor
    func testWeightGoalInteractiveDetection() throws {
        let app = XCUIApplication()
        app.launch()

        let baseDir = "/Users/barenbaruna/.gemini/antigravity-ide/brain/ef144f10-1d22-488a-99da-9764902a2849"
        let scratchPath = "\(baseDir)/scratch"

        // 1. Tap Weight Goal Tab in TabBar
        let weightGoalTab = app.tabBars.buttons["Weight Goal"]
        XCTAssertTrue(weightGoalTab.waitForExistence(timeout: 5))
        weightGoalTab.tap()

        // 2. Verify Weight Goal view, single dynamic badge, and initial 56 kg (Lose Weight)
        XCTAssertTrue(app.staticTexts["Weight Goal"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["56"].exists)
        XCTAssertTrue(app.staticTexts["Lose Weight"].exists)
        let cuttingData = app.screenshot().pngRepresentation
        try? cuttingData.write(to: URL(fileURLWithPath: "\(scratchPath)/weight_goal_tab_verified.png"))

        // 3. Test Done Button
        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.exists)
    }
}

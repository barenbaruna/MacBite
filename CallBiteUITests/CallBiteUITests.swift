//
//  CallBiteUITests.swift
//  CallBiteUITests
//
//  Created by Baren Baruna Harahap on 31/08/26.
//

import Foundation
import XCTest

final class CallBiteUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation
        // - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // XCUIAutomation Documentation
        // https://developer.apple.com/documentation/xcuiautomation
    }

    @MainActor
    func testDashboardShowMoreExpands() throws {
        // Given
        let app = XCUIApplication()
        app.launchArguments = ["-testDashboard"]
        app.launch()
        let showMoreButton = app.buttons["Show More"]

        // When
        XCTAssertTrue(showMoreButton.waitForExistence(timeout: 3))
        XCTAssertTrue(showMoreButton.isHittable)
        showMoreButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

        // Then
        XCTAssertTrue(app.buttons["Show Less"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testCalendarOpensWithTodayVisibleAndInset() throws {
        // Given
        let app = XCUIApplication()
        app.launchArguments = ["-testDashboard"]
        app.launch()
        let locale = Locale(identifier: "id_ID")
        let todayText = Date.now.formatted(
            .dateTime
                .weekday(.wide)
                .day()
                .month(.wide)
                .year()
                .locale(locale)
        )
        let currentMonthText = Date.now.formatted(
            .dateTime
                .month(.abbreviated)
                .locale(locale)
        )

        // When
        let calendarButton = app.buttons["Open Calendar"]
        XCTAssertTrue(calendarButton.waitForExistence(timeout: 3))
        calendarButton.tap()

        // Then
        let todayButton = app.buttons.matching(
            NSPredicate(format: "label BEGINSWITH %@", todayText)
        ).firstMatch
        XCTAssertTrue(todayButton.waitForExistence(timeout: 3))
        XCTAssertTrue(todayButton.isHittable)

        let currentMonthHeader = app.staticTexts[currentMonthText].firstMatch
        XCTAssertTrue(currentMonthHeader.waitForExistence(timeout: 2))
        XCTAssertGreaterThanOrEqual(currentMonthHeader.frame.minX, 20)
    }

    @MainActor
    func testFoodDetailKeyboardKeepsSaveActionVisible() throws {
        // Given
        let app = XCUIApplication()
        app.launchArguments = ["-testDashboardReview"]
        app.launch()
        let caloriesField = app.textFields["Calories"]
        let mealMetadata = app.staticTexts["Breakfast | 4 September 2026"]

        XCTAssertTrue(app.navigationBars["Food Details"].waitForExistence(timeout: 3))
        XCTAssertTrue(mealMetadata.waitForExistence(timeout: 3))
        XCTAssertFalse(app.buttons["Breakfast"].exists)

        // When
        XCTAssertTrue(caloriesField.waitForExistence(timeout: 3))
        caloriesField.tap()

        // Then
        let keyboard = app.keyboards.firstMatch
        let saveFoodButton = app.buttons["Save Food"]
        let doneButton = app.buttons["Done"]
        XCTAssertTrue(keyboard.waitForExistence(timeout: 2))
        XCTAssertTrue(saveFoodButton.isHittable)
        XCTAssertTrue(doneButton.waitForExistence(timeout: 2))
        XCTAssertLessThanOrEqual(saveFoodButton.frame.maxY, doneButton.frame.minY)
        XCTAssertLessThanOrEqual(doneButton.frame.minY - saveFoodButton.frame.maxY, 80)

        // When
        app.staticTexts["Food Detail Calories Label"].tap()

        // Then
        let keyboardDismissed = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"),
            object: keyboard
        )
        wait(for: [keyboardDismissed], timeout: 2)

        // When
        caloriesField.tap()

        // Then
        XCTAssertTrue(keyboard.waitForExistence(timeout: 2))
        XCTAssertTrue(doneButton.waitForExistence(timeout: 2))

        // When
        doneButton.tap()

        // Then
        let keyboardDismissedWithDone = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"),
            object: keyboard
        )
        wait(for: [keyboardDismissedWithDone], timeout: 2)
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}

//
//  ManualLoggingViewModelTests.swift
//  CallBiteTests
//
//  Created by Codex on 09/09/26.
//

import Testing
@testable import CallBite

@Suite("ManualLoggingViewModel Tests")
struct ManualLoggingViewModelTests {
    @Test("Manual logging starts with one empty ingredient group")
    @MainActor
    func startsEmpty() {
        let viewModel = ManualLoggingViewModel()

        #expect(viewModel.foodName.isEmpty)
        #expect(viewModel.ingredients.count == 1)
        #expect(viewModel.ingredients[0].ingredient.isEmpty)
        #expect(viewModel.ingredients[0].portionGrams.isEmpty)
        #expect(viewModel.ingredients[0].cookingMethod.isEmpty)
    }

    @Test("Add ingredients appends another empty group")
    @MainActor
    func addsIngredientGroup() {
        let viewModel = ManualLoggingViewModel()

        viewModel.addIngredient()

        #expect(viewModel.ingredients.count == 2)
        #expect(viewModel.ingredients[1].ingredient.isEmpty)
        #expect(viewModel.ingredients[1].portionGrams.isEmpty)
        #expect(viewModel.ingredients[1].cookingMethod.isEmpty)
    }

    @Test("Manual fields update their matching values")
    @MainActor
    func updatesFields() {
        let viewModel = ManualLoggingViewModel()
        let ingredientID = viewModel.ingredients[0].id

        viewModel.updateFoodName("Chicken Soup")
        viewModel.updateIngredient("Chicken", id: ingredientID)
        viewModel.updatePortionGrams("100", id: ingredientID)
        viewModel.updateCookingMethod("Boiled", id: ingredientID)

        #expect(viewModel.foodName == "Chicken Soup")
        #expect(viewModel.ingredients[0].ingredient == "Chicken")
        #expect(viewModel.ingredients[0].portionGrams == "100")
        #expect(viewModel.ingredients[0].cookingMethod == "Boiled")
    }
}

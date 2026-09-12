//
//  ManualLoggingViewModelTests.swift
//  CallBiteTests
//
//  Created by Codex on 09/09/26.
//

@testable import CallBite
import Testing

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
    }

    @Test("Add ingredients appends another empty group")
    @MainActor
    func addsIngredientGroup() {
        let viewModel = ManualLoggingViewModel()

        viewModel.addIngredient()

        #expect(viewModel.ingredients.count == 2)
        #expect(viewModel.ingredients[1].ingredient.isEmpty)
        #expect(viewModel.ingredients[1].portionGrams.isEmpty)
    }

    @Test("Manual fields update their matching values")
    @MainActor
    func updatesFields() {
        let viewModel = ManualLoggingViewModel()
        let ingredientID = viewModel.ingredients[0].id

        viewModel.updateFoodName("Chicken Soup")
        viewModel.updateIngredient("Chicken", id: ingredientID)
        viewModel.updatePortionGrams("100", id: ingredientID)

        #expect(viewModel.foodName == "Chicken Soup")
        #expect(viewModel.ingredients[0].ingredient == "Chicken")
        #expect(viewModel.ingredients[0].portionGrams == "100")
    }

    @Test("Remove ingredient removes matching group when more than one exists")
    @MainActor
    func removesIngredientGroup() {
        let viewModel = ManualLoggingViewModel()
        viewModel.addIngredient()
        #expect(viewModel.ingredients.count == 2)

        let secondID = viewModel.ingredients[1].id
        viewModel.removeIngredient(id: secondID)

        #expect(viewModel.ingredients.count == 1)

        // Cannot remove last remaining ingredient
        let firstID = viewModel.ingredients[0].id
        viewModel.removeIngredient(id: firstID)
        #expect(viewModel.ingredients.count == 1)
    }
}

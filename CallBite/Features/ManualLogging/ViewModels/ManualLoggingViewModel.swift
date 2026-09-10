//
//  ManualLoggingViewModel.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 01/09/26.
//

import Combine
import Foundation

@MainActor
final class ManualLoggingViewModel: ObservableObject {
    @Published private(set) var foodName = ""
    @Published private(set) var ingredients: [ManualIngredientInput] = [
        ManualIngredientInput()
    ]

    func updateFoodName(_ foodName: String) {
        self.foodName = foodName
    }

    func updateIngredient(_ ingredient: String, id: UUID) {
        updateIngredientGroup(id: id) { group in
            group.ingredient = ingredient
        }
    }

    func updatePortionGrams(_ portionGrams: String, id: UUID) {
        updateIngredientGroup(id: id) { group in
            group.portionGrams = portionGrams
        }
    }

    func updateCookingMethod(_ cookingMethod: String, id: UUID) {
        updateIngredientGroup(id: id) { group in
            group.cookingMethod = cookingMethod
        }
    }

    func addIngredient() {
        ingredients.append(ManualIngredientInput())
    }

    func removeIngredient(id: UUID) {
        guard ingredients.count > 1 else { return }
        ingredients.removeAll(where: { $0.id == id })
    }

    private func updateIngredientGroup(
        id: UUID,
        update: (inout ManualIngredientInput) -> Void
    ) {
        guard let index = ingredients.firstIndex(where: { $0.id == id }) else {
            return
        }

        update(&ingredients[index])
    }
}

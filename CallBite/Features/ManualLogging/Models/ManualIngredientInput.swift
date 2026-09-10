//
//  ManualIngredientInput.swift
//  CallBite
//
//  Created by Codex on 09/09/26.
//

import Foundation

struct ManualIngredientInput: Identifiable, Equatable {
    let id: UUID
    var ingredient: String
    var portionGrams: String
    var cookingMethod: String

    init(
        id: UUID = UUID(),
        ingredient: String = "",
        portionGrams: String = "",
        cookingMethod: String = ""
    ) {
        self.id = id
        self.ingredient = ingredient
        self.portionGrams = portionGrams
        self.cookingMethod = cookingMethod
    }
}

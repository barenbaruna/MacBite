//
//  ManualIngredientInput.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 09/09/26.
//

import Foundation

struct ManualIngredientInput: Identifiable, Equatable {
    let id: UUID
    var ingredient: String
    var portionGrams: String

    init(
        id: UUID = UUID(),
        ingredient: String = "",
        portionGrams: String = ""
    ) {
        self.id = id
        self.ingredient = ingredient
        self.portionGrams = portionGrams
    }
}

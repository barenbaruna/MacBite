//
//  FoodCandidate.swift
//  CallBite
//
//  Created by Fathimah Az Zahra Sanjani on 02/09/26.
//

import Foundation

/// Pure domain model representing an AI-detected food candidate and its confidence score.
public struct FoodCandidate: Identifiable, Equatable, Hashable, Sendable {
    public let id: UUID
    public let name: String
    public let confidence: Double

    public init(id: UUID = UUID(), name: String, confidence: Double) {
        self.id = id
        self.name = name
        self.confidence = confidence
    }
}

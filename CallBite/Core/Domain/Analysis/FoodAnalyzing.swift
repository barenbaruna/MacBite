//
//  FoodAnalyzing.swift
//  CallBite
//
//  Created by Fathimah Az Zahra Sanjani on 02/09/26.
//

import UIKit

/// Contract for anything that can turn a food photo into a `FoodCandidate`.
///
/// A protocol exists here specifically because this service runs ML inference
/// (see 09_Dependency_Injection.md: "Service menjalankan inferensi ML model --
/// buat protocol") — it needs to be mockable for ViewModel unit tests and
/// SwiftUI previews without invoking real CoreML/Foundation Models inference.
///
/// Implementations: `CoreMLFoodAnalyzer` (production, on-device), `MockFoodAnalyzer`
/// (tests/previews). `GeminiFoodAnalyzer` is a scaffolded future alternative,
/// not implemented as part of this pipeline.
///
/// NOTE: this file imports UIKit (for `UIImage`), which deviates from the usual
/// domain-model rule of "only import Foundation" — that rule targets plain data
/// structs, not service-contract protocols. UIImage is the app's standard image
/// representation (already used by `FoodCaptureViewModel`), so no adapter is introduced.
public protocol FoodAnalyzing: Sendable {
    /// Analyzes a single food photo and returns the best candidate result.
    ///
    /// - Parameter image: A captured or picked photo, orientation not yet normalized.
    /// - Returns: A `FoodCandidate` describing the detected dish and its nutrition estimate.
    /// - Throws: `AppError` if the photo fails the food gate, or if preprocessing/inference fails.
    func analyze(_ image: UIImage) async throws -> FoodCandidate
}

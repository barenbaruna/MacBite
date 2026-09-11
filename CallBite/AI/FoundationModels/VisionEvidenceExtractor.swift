//
//  VisionEvidenceExtractor.swift
//  CallBite
//
//  Created by Fathimah Az Zahra Sanjani on 11/09/26.
//
//  Stage 1 of dish naming: gathers generic visual label candidates via Vision
//  (VNClassifyImageRequest), then hands them to FoundationModelFoodNamer for
//  the actual naming reasoning (Stage 2), with a non-LLM taxonomy fallback.
//
//  Ported from FoodNutritionPOC's AppleFoodRecognitionService — renamed here
//  because that name was found to be misleading (it does NOT use Apple
//  Foundation Models directly; Vision is a separate, generic, non-food-specific
//  classifier). See that project's conversation history for the full debugging
//  trail behind every constant below (blacklist entries, confidence threshold).
//

import UIKit
import Vision

/// Gathers Vision evidence and produces a dish name, preferring the on-device
/// Foundation Model for reasoning and falling back to taxonomy-matching when
/// Apple Intelligence isn't available on this device.
final class VisionEvidenceExtractor: @unchecked Sendable {

    // MARK: - Tuning

    /// Minimum confidence for a Vision label to be considered a valid candidate.
    /// VNClassifyImageRequest spreads probability across ~1303 classes at once,
    /// so absolute confidence values tend to be small. PROVISIONAL — raised from
    /// 0.02 to 0.05 based on real log data: genuine food signal usually sits well
    /// above 0.1 (e.g. soup=0.62, vegetable=0.21, curry=0.12), while irrelevant
    /// noise (document, condiment, ladle, printed_page) hovers around 0.03-0.05.
    private static let minLabelConfidence: Float = 0.05

    /// Top-N candidate labels forwarded as context (to the Foundation Model or
    /// the fallback heuristic).
    private static let maxCandidateLabels = 8

    // MARK: - Blacklist

    /// Non-food / tableware terms that must be discarded entirely before any
    /// naming stage (LLM or heuristic) sees them.
    private static let nonFoodBlacklist: [String] = [
        "fork", "spoon", "knife", "cutlery", "utensil", "chopstick",
        "tableware", "dishware", "dinnerware", "flatware", "serveware",
        "plate", "bowl", "saucer", "cup", "mug", "glass", "bottle",
        "napkin", "tray", "table", "tablecloth", "placemat", "table_setting",
        "eating_utensil", "counter", "kitchen", "cookware", "pan", "pot",
        "furniture", "room", "indoor", "container", "plastic",
        // Generic filler with no specific dish name
        "food", "dish", "meal", "eating", "produce", "ingredient",
        "finger_food", "snack", "fast_food", "cuisine", "delicacy", "recipe", "portion",
        // Generic texture/surface/background descriptors (not food) — found
        // slipping through in real log data (e.g. "wood_processed" for a wooden
        // table, "structure"/"material"/"textile" for image composition).
        "structure", "material", "textile", "tool", "wood", "wood_processed", "surface"
    ]

    /// One entry in the fallback taxonomy map. A named struct (not a tuple) to
    /// satisfy SwiftLint's `large_tuple` rule; the positional initializer keeps
    /// the literal table below just as compact as a tuple array would be.
    private struct TaxonomyEntry {
        let keyword: String
        let displayName: String
        let isProtein: Bool
        let isCarb: Bool

        init(_ keyword: String, _ displayName: String, _ isProtein: Bool, _ isCarb: Bool) {
            self.keyword = keyword
            self.displayName = displayName
            self.isProtein = isProtein
            self.isCarb = isCarb
        }
    }

    /// Vision category -> clean culinary name mapping. Used ONLY as a fallback
    /// when Foundation Models is unavailable — not the primary path, since its
    /// coverage is limited (generic Vision classes, no local/composite dishes).
    private static let fallbackTaxonomyMap: [TaxonomyEntry] = [
        // Carbs
        TaxonomyEntry("rice", "Steamed Rice", false, true),
        TaxonomyEntry("fried_rice", "Fried Rice", false, true),
        TaxonomyEntry("pasta", "Pasta", false, true),
        TaxonomyEntry("noodle", "Noodles", false, true),
        TaxonomyEntry("potato", "Potatoes", false, true),
        TaxonomyEntry("white_bread", "Bread", false, true),
        TaxonomyEntry("bread", "Bread", false, true),
        TaxonomyEntry("pancake", "Pancake", false, true),

        // Protein & sides
        TaxonomyEntry("grilled_chicken", "Grilled Chicken", true, false),
        TaxonomyEntry("fried_chicken", "Fried Chicken", true, false),
        TaxonomyEntry("chicken", "Chicken", true, false),
        TaxonomyEntry("steak", "Beef Steak", true, false),
        TaxonomyEntry("beef", "Beef", true, false),
        TaxonomyEntry("meatball", "Meatballs", true, false),
        TaxonomyEntry("meat", "Meat Cut", true, false),
        TaxonomyEntry("salmon", "Grilled Salmon", true, false),
        TaxonomyEntry("fish", "Fish", true, false),
        TaxonomyEntry("shellfish_prepared", "Seafood", true, false),
        TaxonomyEntry("fried_egg", "Fried Egg", true, false),
        TaxonomyEntry("scrambled_eggs", "Scrambled Eggs", true, false),
        TaxonomyEntry("egg", "Egg", true, false),
        TaxonomyEntry("bean", "Beans", true, false),
        TaxonomyEntry("cheese", "Cheese", true, false),

        // Vegetables & sides
        TaxonomyEntry("salad", "Fresh Salad", false, false),
        TaxonomyEntry("green_beans", "Green Beans", false, false),
        TaxonomyEntry("vegetable", "Mixed Vegetables", false, false),
        TaxonomyEntry("pepper_veggie", "Bell Peppers", false, false),
        TaxonomyEntry("eggplant", "Eggplant", false, false),
        TaxonomyEntry("tomato", "Tomatoes", false, false),

        // Whole dishes
        TaxonomyEntry("curry", "Curry Dish", true, false),
        TaxonomyEntry("soup", "Warm Soup", false, false),
        TaxonomyEntry("sushi", "Sushi", true, true),
        TaxonomyEntry("pizza", "Pizza", false, true),
        TaxonomyEntry("hamburger", "Burger", true, true),
        TaxonomyEntry("sandwich", "Sandwich", true, true),
        TaxonomyEntry("taco", "Taco", true, true)
    ]

    // MARK: - Recognition Pipeline

    /// Identify a dish name & components from a food photo.
    func identify(from image: UIImage) async throws -> (name: String, components: [String]) {
        guard let cgImage = image.cgImage else {
            throw AppError.imageDecodeFailed
        }

        let observations = try await classify(cgImage: cgImage)
        let labels = filteredLabels(from: observations)

        guard FoundationModelFoodNamer.isAvailable else {
            return buildHeuristicResult(from: labels)
        }

        do {
            let humanReadable = labels.map { $0.replacingOccurrences(of: "_", with: " ") }
            // A new session per call, for simplicity — see FoundationModelFoodNamer.
            return try await FoundationModelFoodNamer().name(fromLabels: humanReadable)
        } catch {
            // Foundation Model failed at runtime (guardrail, resource pressure, etc).
            // Don't fail the whole pipeline just because naming failed.
            return buildHeuristicResult(from: labels)
        }
    }

    // MARK: - Stage 1: Vision Evidence Gathering

    private func classify(cgImage: CGImage) async throws -> [VNClassificationObservation] {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNClassifyImageRequest { req, error in
                if let error {
                    continuation.resume(throwing: AppError.inferenceFailed("Vision request failed: \(error.localizedDescription)"))
                    return
                }

                guard let observations = req.results as? [VNClassificationObservation] else {
                    continuation.resume(throwing: AppError.inferenceFailed("No vision classification results"))
                    return
                }

                continuation.resume(returning: observations)
            }

            #if targetEnvironment(simulator)
            request.usesCPUOnly = true
            #endif

            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: AppError.inferenceFailed(error.localizedDescription))
            }
        }
    }

    /// Blacklist + confidence-threshold filter. Returns RAW Vision identifiers
    /// (underscore-style, e.g. "fried_chicken") for taxonomy matching; converted
    /// to human-readable form by the caller before reaching the Foundation Model.
    private func filteredLabels(from observations: [VNClassificationObservation]) -> [String] {
        observations
            .filter { $0.confidence >= Self.minLabelConfidence }
            .map { $0.identifier.lowercased() }
            .filter { id in
                !Self.nonFoodBlacklist.contains { term in
                    id == term || id.contains("_\(term)") || id.contains("\(term)_")
                }
            }
            .prefix(Self.maxCandidateLabels)
            .map { $0 }
    }

    // MARK: - Stage 2 (Fallback): Taxonomy Heuristic

    /// Build a dish name & components from raw labels without LLM help. Used
    /// only when Foundation Models is unavailable on this device.
    private func buildHeuristicResult(from labels: [String]) -> (name: String, components: [String]) {
        var detectedLauk: [TaxonomyEntry] = []
        var detectedNamesSet: Set<String> = []

        for id in labels {
            for item in Self.fallbackTaxonomyMap {
                if id == item.keyword || id.contains("_\(item.keyword)") || id.contains("\(item.keyword)_") {
                    if !detectedNamesSet.contains(item.displayName) {
                        detectedNamesSet.insert(item.displayName)
                        detectedLauk.append(item)
                    }
                    break
                }
            }
        }

        var components = detectedLauk.map { $0.displayName }

        let proteins = detectedLauk.filter { $0.isProtein }.map { $0.displayName }
        let carbs = detectedLauk.filter { $0.isCarb }.map { $0.displayName }
        let others = detectedLauk.filter { !$0.isProtein && !$0.isCarb }.map { $0.displayName }

        let dishName: String

        if let carb = carbs.first, let protein = proteins.first {
            dishName = "\(carb) with \(protein)"
        } else if let protein = proteins.first, let side = others.first {
            dishName = "\(protein) with \(side)"
        } else if let mainProtein = proteins.first {
            dishName = "\(mainProtein) Plate"
        } else if let mainCarb = carbs.first {
            dishName = "\(mainCarb) Dish"
        } else if let firstComponent = components.first {
            dishName = "\(firstComponent) Plate"
        } else {
            // No label matched this limited taxonomy — most common for local
            // dishes outside the ~30 classes above.
            dishName = "Mixed Food Plate"
            components = ["Rice / Carb", "Main Protein / Lauk", "Vegetables"]
        }

        return (name: dishName, components: Array(components.prefix(4)))
    }
}

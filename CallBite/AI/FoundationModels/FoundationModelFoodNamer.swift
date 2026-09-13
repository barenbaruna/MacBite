//
//  FoundationModelFoodNamer.swift
//  CallBite
//
//  Created by Fathimah Az Zahra Sanjani on 11/09/26.
//
//

import Foundation
import FoundationModels

final class FoundationModelFoodNamer: @unchecked Sendable {

    // MARK: - Generation Schema

    /// LANGUAGE NOTE: every string below (instructions, @Guide, prompt) is
    /// DELIBERATELY English. The on-device Apple Intelligence model rejects
    /// Bahasa Indonesia instructions/prompts with "Unsupported language id
    /// detected." — found via runtime testing in FoodNutritionPOC. Do NOT
    /// translate this to Indonesian, even though 02_Coding_Standards.md
    /// otherwise mandates Indonesian for user-facing strings — this text never
    /// reaches the user, it is an internal LLM instruction.
    @Generable
    struct GeneratedFoodName {
        @Guide(description: """
        A clear, natural culinary dish name. If the label pattern matches a popular \
        dish from any cuisine (including Indonesian dishes such as nasi goreng, \
        rendang, sate ayam, soto, gado-gado, mie goreng, bakso), use that dish name. \
        If the labels are too generic/ambiguous, use a neutral descriptive name, \
        e.g. "Mixed Rice Plate". IMPORTANT: this app is for nutrition/calorie \
        logging, so the main protein source (meat, poultry, fish, egg, tofu, \
        tempeh, etc.) is the most nutritionally significant part of the meal — \
        if a protein label is present in the input, it MUST be named in the dish \
        name itself, not only listed as a component. Do not let a less significant \
        side (e.g. a vegetable or mushroom) take the protein's place in the title.
        """)
        var foodName: String

        @Guide(description: """
        Up to 4 main components/side dishes that are actually visible on the plate \
        based on the given labels. Do not include cutlery or tableware.
        """)
        var components: [String]
    }

    // MARK: - Availability

    /// Whether Apple Intelligence / Foundation Models is actually usable on this
    /// device right now. Can be false even on iOS 26.5 (device not eligible,
    /// Apple Intelligence disabled in Settings, or model still downloading).
    static var isAvailable: Bool {
        SystemLanguageModel.default.availability == .available
    }

    // MARK: - Session

    private static let instructions = """
    You identify food dishes from a list of rough visual labels produced by a \
    generic image classifier (not a food-specific model), for a nutrition/calorie \
    logging app. The labels are ordered from most to least confident, and CAN be \
    wrong, overlapping, or incomplete — use your reasoning, don't just concatenate \
    the labels literally. Ignore any label that clearly refers to background/\
    surface/material rather than food (e.g. "structure", "material", "textile", \
    "wood_processed").

    Rules:
    - Infer ONE most plausible dish name from the combination of labels given.
    - CRITICAL: because this is for nutrition logging, the main protein source \
      (meat, poultry, fish, egg, tofu, tempeh, etc.) is the most important part \
      of the dish name — if any protein label is present, name it explicitly in \
      the dish name (e.g. "Fried Rice with Fried Chicken", not just "Fried Rice \
      with Mushroom and Vegetable" when chicken is also present). Never bury a \
      detected protein inside components only.
    - Do not invent ingredients that are entirely unsupported by the given labels.
    - Do not include plates, spoons, forks, or other tableware as components.
    - If unsure, prefer an honest generic name over guessing a specific dish name \
      that isn't supported by evidence.
    """

    private let session: LanguageModelSession

    init() {
        session = LanguageModelSession(instructions: Self.instructions)
    }

    // MARK: - Inference

    /// Infer a dish name & components from a list of human-readable visual
    /// labels (e.g. "fried chicken", "rice" — already blacklist-filtered).
    ///
    /// - Throws: `AppError.inferenceFailed` if the model session fails (guardrail,
    ///   resource pressure, timeout). Caller should fall back to a non-LLM
    ///   heuristic rather than surfacing this error to the user.
    func name(fromLabels labels: [String]) async throws -> (name: String, components: [String]) {
        guard !labels.isEmpty else {
            throw AppError.inferenceFailed("No valid visual labels for Foundation Model.")
        }

        // Prompt stays English — see language note on GeneratedFoodName above.
        let prompt = "Detected visual labels (highest to lowest confidence): \(labels.joined(separator: ", "))."

        do {
            // sampling: .greedy => always pick the most likely token at each step,
            // instead of random sampling. Without this, the EXACT SAME input labels
            // can produce a different dish name on every run (LLM non-determinism)
            // — found via real testing: identical labels produced "Fried Rice with
            // Mushroom..." on one run and "Fried Chicken Rice Soup" on another.
            // Greedy doesn't guarantee the "best" quality, but guarantees
            // consistency for the same evidence.
            let response = try await session.respond(
                to: prompt,
                generating: GeneratedFoodName.self,
                options: GenerationOptions(sampling: .greedy)
            )
            let generated = response.content
            return (name: generated.foodName, components: Array(generated.components.prefix(4)))
        } catch {
            throw AppError.inferenceFailed("Foundation Model failed: \(error.localizedDescription)")
        }
    }
}

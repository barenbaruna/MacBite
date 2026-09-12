//
//  FoodGateService.swift
//  CallBite
//
//  Created by Fathimah Az Zahra Sanjani on 11/09/26.
//
//  Wraps FoodGate.mlpackage (csatv2.r512_in1k) — food/non-food classification.
//  Ported from FoodNutritionPOC (validated: parity test max diff ~0.00000003
//  against the PyTorch source model, see that project's CoreMLConversionReport.md).
//

import CoreML
import UIKit

/// Result of a food/non-food gate classification.
struct FoodGateResult {
    /// Probability the image is food/drink (class index 0). Range [0, 1].
    let foodProbability: Double

    /// Whether this passes the food threshold.
    var isFood: Bool { foodProbability >= FoodGateService.threshold }
}

/// Food/non-food gate inference. Model is loaded ONCE at init and reused.
final class FoodGateService {

    /// Provisional threshold — not yet calibrated against real camera photos
    /// (only validated against synthetic parity-test images). See
    /// FoodNutritionPOC/README.md "Keterbatasan Model" for the same caveat.
    static let threshold: Double = 0.50

    private static let modelName = "FoodGate"

    private let model: MLModel
    private let preprocessing = ImagePreprocessingService()

    init() throws {
        let compiledURL: URL
        if let modelcURL = Bundle.main.url(forResource: Self.modelName, withExtension: "mlmodelc") {
            compiledURL = modelcURL
        } else if let packageURL = Bundle.main.url(forResource: Self.modelName, withExtension: "mlpackage") {
            do {
                compiledURL = try MLModel.compileModel(at: packageURL)
            } catch {
                throw AppError.modelLoadFailed("\(Self.modelName): \(error.localizedDescription)")
            }
        } else {
            throw AppError.modelNotFound(Self.modelName)
        }

        let config = MLModelConfiguration()
        // .cpuAndGPU, NOT .all — deliberately skips the Neural Engine.
        // Found via real DEVICE testing (not just Simulator): FoodGate's custom
        // ops (the rank5 DCT reshape + GRN workarounds from FoodNutritionPOC,
        // needed to satisfy the MIL *graph* compiler) still fail the separate
        // ANE-specific compiler ("MILCompilerForANE ... ANECCompile() FAILED")
        // even on real hardware. CPU+GPU compiles and runs fine.
        config.computeUnits = .cpuAndGPU

        do {
            self.model = try MLModel(contentsOf: compiledURL, configuration: config)
        } catch {
            throw AppError.modelLoadFailed("\(Self.modelName): \(error.localizedDescription)")
        }
    }

    /// Run food gate inference on an image.
    func classify(_ image: UIImage) throws -> FoodGateResult {
        let pixelBuffer = try preprocessing.prepareForGate(image)

        let input = try MLDictionaryFeatureProvider(dictionary: ["image": pixelBuffer])

        let output: MLFeatureProvider
        do {
            output = try model.prediction(from: input)
        } catch {
            throw AppError.inferenceFailed("FoodGate: \(error.localizedDescription)")
        }

        // Index 0 = food_or_drink per the model's training/export contract.
        guard let multiArray = output.featureValue(for: "class_probabilities")?.multiArrayValue else {
            throw AppError.inferenceFailed("FoodGate: invalid 'class_probabilities' output.")
        }

        let foodProb = Double(truncating: multiArray[0])
        return FoodGateResult(foodProbability: foodProb)
    }
}

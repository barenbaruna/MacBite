//
//  NutritionRegressionService.swift
//  CallBite
//
//  Created by Fathimah Az Zahra Sanjani on 11/09/26.
//
//  Wraps NutritionADMD.mlpackage (rgb_student_admd_nutrition_torchscript) —
//  nutrition regression from a single RGB photo. Ported from FoodNutritionPOC
//  (validated: parity test max diff <0.001 against the PyTorch source model).
//
//  IMPORTANT:
//  - The model does NOT produce a confidence score, and does NOT predict fiber.
//  - /255 scaling and ImageNet normalization are already embedded in the
//    .mlpackage wrapper. Do not normalize again here.
//

import CoreML
import UIKit

/// Raw regression output, order preserved exactly as trained/exported:
/// [calories_kcal, mass_g, fat_g, carbs_g, protein_g].
/// (A named struct, not a tuple, to satisfy SwiftLint's `large_tuple` rule.)
struct NutritionRegressionOutput {
    let calories: Double
    let massGrams: Double
    let fat: Double
    let carbs: Double
    let protein: Double
}

/// Nutrition regression inference. Model is loaded ONCE at init and reused.
final class NutritionRegressionService {

    private static let modelName = "NutritionADMD"

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
        // .cpuAndGPU, NOT .all — see the same note in FoodGateService.swift.
        // Confirmed via real DEVICE testing that requesting the Neural Engine
        // for this model pairing triggers "MILCompilerForANE ...
        // ANECCompile() FAILED" — not just a Simulator-only issue.
        config.computeUnits = .cpuAndGPU

        do {
            self.model = try MLModel(contentsOf: compiledURL, configuration: config)
        } catch {
            throw AppError.modelLoadFailed("\(Self.modelName): \(error.localizedDescription)")
        }
    }

    /// Run nutrition regression on a food image that already passed the food gate.
    func predict(_ image: UIImage) throws -> NutritionRegressionOutput {
        let pixelBuffer = try preprocessing.prepareForNutrition(image)

        let input = try MLDictionaryFeatureProvider(dictionary: ["image": pixelBuffer])

        let output: MLFeatureProvider
        do {
            output = try model.prediction(from: input)
        } catch {
            throw AppError.inferenceFailed("NutritionADMD: \(error.localizedDescription)")
        }

        guard let multiArray = output.featureValue(for: "nutrition_output")?.multiArrayValue,
              multiArray.count >= 5 else {
            throw AppError.inferenceFailed("NutritionADMD: invalid or wrong-sized 'nutrition_output'.")
        }

        let values = (0..<5).map { Double(truncating: multiArray[$0]) }
        return NutritionRegressionOutput(
            calories: values[0],
            massGrams: values[1],
            fat: values[2],
            carbs: values[3],
            protein: values[4]
        )
    }
}

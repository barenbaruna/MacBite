//
//  AppError.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import Foundation

/// Centralized error type for the app (see 02_Coding_Standards.md: "Semua error
/// dalam aplikasi menggunakan tipe AppError yang terpusat").
///
/// Cases below cover the AI food-analysis pipeline (`ml(analysis)` work). Other
/// features may add more cases here as they need centralized error handling —
/// this is not meant to be an exhaustive, final list.
public enum AppError: LocalizedError, Equatable, Sendable {
    // MARK: - AI Analysis
    case modelNotFound(String)
    case modelLoadFailed(String)
    case inferenceFailed(String)
    case nonFoodDetected(probability: Double)
    case imageDecodeFailed

    /// User-facing message. Always Bahasa Indonesia (see 02_Coding_Standards.md).
    public var errorDescription: String? {
        switch self {
        case .modelNotFound(let name):
            return "Model \(name) tidak ditemukan. Coba restart aplikasi."
        case .modelLoadFailed(let name):
            return "Gagal memuat model \(name). Coba restart aplikasi."
        case .inferenceFailed:
            return "Gagal menganalisis foto makanan. Silakan coba lagi."
        case .nonFoodDetected(let probability):
            let percent = String(format: "%.0f%%", probability * 100)
            return "Foto terdeteksi bukan makanan (\(percent)). Silakan ambil foto ulang."
        case .imageDecodeFailed:
            return "Gagal membaca foto. Pastikan file foto tidak rusak."
        }
    }
}

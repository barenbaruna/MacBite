//
//  BiologicalSex.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 08/09/26.
//

import Foundation

enum BiologicalSex: String, CaseIterable, Identifiable {
    case male
    case female

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        }
    }
}

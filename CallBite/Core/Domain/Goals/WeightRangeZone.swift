//
//  WeightRangeZone.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 11/09/26.
//

import Foundation

/// Categorization of the user's weight goal relative to scientific recommended ranges.
enum WeightRangeZone: String, CaseIterable, Equatable {
    case belowRecommended = "BELOW RECOMMENDED RANGE"
    case recommended = "RECOMMENDED RANGE"
    case aboveRecommended = "ABOVE RECOMMENDED RANGE"

    var title: String {
        rawValue
    }
}

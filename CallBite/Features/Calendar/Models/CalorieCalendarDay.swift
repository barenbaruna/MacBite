//
//  CalorieCalendarDay.swift
//  CallBite
//
//  Created by Codex on 10/09/26.
//

import Foundation

struct CalorieCalendarDay: Identifiable, Equatable {
    let id: String
    let date: Date?
    let dayNumber: Int?
    let summary: DailySummary?
    let isSelectable: Bool
}

//
//  CalorieCalendarMonth.swift
//  CallBite
//
//  Created by Codex on 10/09/26.
//

import Foundation

struct CalorieCalendarMonth: Identifiable, Equatable {
    let id: Date
    let startDate: Date
    let days: [CalorieCalendarDay]
}

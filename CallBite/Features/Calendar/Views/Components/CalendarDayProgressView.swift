//
//  CalendarDayProgressView.swift
//  CallBite
//
//  Created by Codex on 10/09/26.
//

import SwiftUI

struct CalendarDayProgressView: View {
    let dayNumber: Int
    let summary: DailySummary?

    private var progress: Double {
        guard let summary, summary.targetCalories > 0 else { return 0 }
        return Double(summary.consumedCalories) / Double(summary.targetCalories)
    }

    var body: some View {
        ZStack {
            trackRing

            if progress > 0 {
                primaryProgressRing
            }

            if progress > 0 && progress < 1 {
                partialProgressStartCap
            }

            if progress > 1 {
                overflowProgressRing
            }

            dayLabel
        }
        .frame(
            width: AppSize.calendarDayIndicator,
            height: AppSize.calendarDayIndicator
        )
        .accessibilityHidden(true)
    }

    private var trackRing: some View {
        Circle()
            .stroke(AppColor.ringTrack, lineWidth: AppSize.calendarDayRingStroke)
    }

    private var primaryProgressRing: some View {
        let gradient: AngularGradient
        if progress > 1 {
            gradient = AppGradient.calorieOverlimitBase
        } else if progress >= 1 {
            gradient = AppGradient.completedCalorieRing
        } else {
            gradient = AppGradient.calorieRing
        }

        return Circle()
            .trim(from: 0, to: min(1, progress))
            .stroke(gradient, style: primaryRingStrokeStyle)
            .rotationEffect(.degrees(AppMetrics.calorieRingStartAngle))
    }

    private var partialProgressStartCap: some View {
        Circle()
            .fill(AppColor.ringYellow)
            .frame(width: AppSize.calendarDayRingStroke, height: AppSize.calendarDayRingStroke)
            .offset(y: -(AppSize.calendarDayIndicator / 2))
    }

    private var overflowProgressRing: some View {
        let overflow = min(1, max(0, progress - 1))
        let overlapDegrees = AppMetrics.calorieRingSeamOverlapDegrees
        let overlapFraction = overlapDegrees / 360
        return Circle()
            .trim(from: 0, to: min(1, overlapFraction + overflow))
            .stroke(AppGradient.calorieOverflow, style: overflowRingStrokeStyle)
            .rotationEffect(.degrees(AppMetrics.calorieRingStartAngle - overlapDegrees))
    }

    private var dayLabel: some View {
        Text(dayNumber, format: .number)
            .font(AppTypography.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(AppColor.white)
            .monospacedDigit()
    }

    private var primaryRingStrokeStyle: StrokeStyle {
        StrokeStyle(
            lineWidth: AppSize.calendarDayRingStroke,
            lineCap: progress < 1 ? .round : .butt
        )
    }

    private var overflowRingStrokeStyle: StrokeStyle {
        StrokeStyle(
            lineWidth: AppSize.calendarDayRingStroke,
            lineCap: .round
        )
    }
}

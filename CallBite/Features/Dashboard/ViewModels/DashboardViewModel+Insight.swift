//
//  DashboardViewModel+Insight.swift
//  CallBite
//
//  Created by Fathimah Az Zahra Sanjani on 12/09/26.
//
//  Coach insight generation — mirrors the DashboardViewModel+Analysis.swift
//  pattern (a dedicated extension per AI concern, rather than everything
//  crammed into the main DashboardViewModel.swift).
//
//  coachInsight used to live as a computed property on the DailySummary
//  domain model (pure, synchronous rule-based text). It moved here because
//  generating it now requires an async Foundation Model call, which a
//  domain model must never own (01_Architecture.md: "domain model tidak
//  boleh berisi logika side-effect... logika tersebut ada di Service").
//

import Foundation

extension DashboardViewModel {
    /// Refreshes `coachInsight` for the CURRENT `dailySummary`/`selectedDate`.
    /// Call this any time either changes (after saving a meal, or after
    /// switching days) — see call sites in DashboardViewModel.swift's
    /// `init`, `phaseStartOrbitAndFillProgress()`, `executeReduceMotionFallback()`,
    /// and `selectDate(_:)`.
    ///
    /// Sets the rule-based fallback text IMMEDIATELY (synchronous — the UI
    /// never shows a blank/stale insight), then asynchronously replaces it
    /// with the Foundation Model's version if generation succeeds.
    func refreshCoachInsight() {
        coachInsight = fallbackCoachInsight(for: dailySummary)

        // Guard against a slow response landing after the user has already
        // navigated to a different day — the one realistic race here, since
        // meals are otherwise logged one at a time through a gated ~2s
        // save animation.
        let requestedDate = selectedDate
        let summaryAtRequestTime = dailySummary

        Task { [weak self] in
            guard let self else { return }
            do {
                let insight = try await self.insightGenerator.generateInsight(for: summaryAtRequestTime)
                guard self.selectedDate == requestedDate else { return }
                self.coachInsight = insight
            } catch {
                // Fallback text set above already stands — nothing further to do.
            }
        }
    }

    /// The rule-based insight this app used before AI generation existed —
    /// kept as the instant fallback (and permanent fallback if Foundation
    /// Models is unavailable/fails). Ported from the old
    /// `DailySummary.coachInsight`, with one bug fixed: the "plenty of
    /// calories left" branch previously hardcoded "200 kcal remaining"
    /// regardless of the actual value — it now uses `remainingCalories`.
    func fallbackCoachInsight(for summary: DailySummary) -> String {
        let remaining = summary.remainingCalories
        if remaining <= 0 {
            return "Goal reached! You've met your target for today."
        } else if remaining <= 300 {
            return "Heads up! You have \(remaining) kcal remaining.\n" +
                "Consider a lighter option for your next meal."
        } else {
            return "You have \(remaining) kcal remaining today.\n" +
                "You're on track — keep it balanced for your next meal."
        }
    }
}

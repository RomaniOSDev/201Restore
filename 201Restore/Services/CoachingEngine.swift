import Foundation

final class CoachingEngine {
    private let recoveryEngine: RecoveryEngine

    init(recoveryEngine: RecoveryEngine) {
        self.recoveryEngine = recoveryEngine
    }

    // MARK: - Today's Decision

    func makeTodayDecision(date: Date = Date()) -> TrainingDecision {
        let entry = recoveryEngine.getEntry(for: date)
        let injuries = recoveryEngine.getActiveInjuries()
        let protocolBoost = recoveryEngine.yesterdayProtocolBonus(relativeTo: date)
        return makeDecision(entry: entry, activeInjuries: injuries, protocolBonus: protocolBoost, date: date)
    }

    func makeDecision(
        entry: RecoveryEntry?,
        activeInjuries: [Injury],
        protocolBonus: Double,
        date: Date = Date()
    ) -> TrainingDecision {
        var reasons: [DecisionReason] = []
        let base = entry?.recoveryIndex ?? 45
        if entry == nil {
            reasons.append(
                DecisionReason(
                    factor: .missingData,
                    detail: "No condition logged yet — readiness estimated conservatively.",
                    impact: -10
                )
            )
        }

        if let entry {
            if entry.sleepQuality <= 4 {
                reasons.append(DecisionReason(factor: .sleep, detail: "Sleep quality is low (\(entry.sleepQuality)/10).", impact: -12))
            } else if entry.sleepQuality >= 8 {
                reasons.append(DecisionReason(factor: .sleep, detail: "Sleep looks solid (\(entry.sleepQuality)/10).", impact: 6))
            }

            if entry.fatigue >= 7 {
                reasons.append(DecisionReason(factor: .fatigue, detail: "Fatigue is elevated (\(entry.fatigue)/10).", impact: -14))
            }
            if entry.muscleSoreness >= 7 {
                reasons.append(DecisionReason(factor: .soreness, detail: "Muscle soreness is high (\(entry.muscleSoreness)/10).", impact: -12))
            }
            if entry.energy <= 4 {
                reasons.append(DecisionReason(factor: .energy, detail: "Energy is low (\(entry.energy)/10).", impact: -10))
            } else if entry.energy >= 8 {
                reasons.append(DecisionReason(factor: .energy, detail: "Energy is high (\(entry.energy)/10).", impact: 5))
            }
            if entry.mood <= 4 {
                reasons.append(DecisionReason(factor: .mood, detail: "Mood is low (\(entry.mood)/10).", impact: -6))
            }
        }

        let bodyLoad = activeInjuries.map(loadStatus(for:))
        let injuryPenalty = min(
            activeInjuries.reduce(0.0) { partial, injury in
                partial + min(Double(injury.painLevel) * 2.8, 22)
            },
            40
        )

        for injury in activeInjuries.sorted(by: { $0.painLevel > $1.painLevel }).prefix(3) {
            reasons.append(
                DecisionReason(
                    factor: .injury,
                    detail: "\(injury.bodyPart.rawValue) pain \(injury.painLevel)/10 limits \(injury.bodyPart.loadZone.rawValue.lowercased()).",
                    impact: -min(injury.painLevel * 2, 16)
                )
            )
        }

        if protocolBonus > 0 {
            reasons.append(
                DecisionReason(
                    factor: .protocolBoost,
                    detail: "Yesterday’s recovery protocol was mostly completed (+\(Int(protocolBonus)) readiness).",
                    impact: Int(protocolBonus)
                )
            )
        }

        let readiness = min(max(base - injuryPenalty + protocolBonus, 0), 100)
        let restricted = restrictedZones(from: bodyLoad)
        let (kind, load, session) = classify(
            readiness: readiness,
            restricted: restricted,
            bodyLoad: bodyLoad,
            entry: entry
        )

        let summary: String
        switch kind {
        case .trainHard:
            summary = "Green light for quality work. Keep form sharp and stop if pain spikes."
        case .trainEasy:
            summary = "Train, but keep intensity capped. Prioritize technique over volume."
        case .activeRecovery:
            summary = "Move to recover: blood flow, mobility, and easy aerobic work only."
        case .rest:
            summary = "Protect recovery today. Rest or walk only — rebuild capacity."
        }

        return TrainingDecision(
            kind: kind,
            readinessScore: readiness,
            baseRecoveryIndex: base,
            injuryPenalty: injuryPenalty,
            protocolBonus: protocolBonus,
            recommendedLoadPercent: load,
            sessionType: session,
            restrictedZones: restricted,
            reasons: reasons.sorted { abs($0.impact) > abs($1.impact) },
            bodyLoad: bodyLoad,
            summary: summary,
            createdAt: date
        )
    }

    func canLoad(_ bodyPart: BodyPart) -> BodyPartLoadStatus {
        if let injury = recoveryEngine.getActiveInjuries().first(where: { $0.bodyPart == bodyPart }) {
            return loadStatus(for: injury)
        }
        return BodyPartLoadStatus(
            bodyPart: bodyPart,
            painLevel: 0,
            advice: .ok,
            message: "No active injury logged for \(bodyPart.rawValue)."
        )
    }

    // MARK: - Insights

    func generateInsights() -> [Insight] {
        let entries = recoveryEngine.getEntries().sorted { $0.date < $1.date }
        let sessions = recoveryEngine.getSessionLogs()
        let injuries = recoveryEngine.getInjuries()
        var insights: [Insight] = []
        let calendar = Calendar.current

        // Sleep below 6 for 3 consecutive logged days
        let recent = Array(entries.suffix(7))
        if recent.count >= 3 {
            var streak = 0
            var maxLow = 0
            for entry in recent.reversed() {
                if entry.sleepQuality < 6 {
                    streak += 1
                    maxLow = max(maxLow, streak)
                } else {
                    streak = 0
                }
            }
            if maxLow >= 3 {
                let avg = recent.map(\.recoveryIndex).reduce(0, +) / Double(recent.count)
                let baseline = entries.dropLast(recent.count)
                let baseAvg = baseline.isEmpty
                    ? avg
                    : baseline.map(\.recoveryIndex).reduce(0, +) / Double(baseline.count)
                let delta = Int((avg - baseAvg).rounded())
                insights.append(
                    Insight(
                        title: "Sleep debt pattern",
                        message: "Sleep below 6/10 for \(maxLow) recent days. Average readiness moved \(delta >= 0 ? "+" : "")\(delta)% vs earlier baseline.",
                        severity: .warning,
                        icon: "bed.double.fill"
                    )
                )
            }
        }

        // Soreness after lower-body sessions
        var postLowerSoreness: [Int] = []
        for session in sessions where session.intent?.involvesLower == true {
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: session.date),
               let nextEntry = recoveryEngine.getEntry(for: nextDay) {
                postLowerSoreness.append(nextEntry.muscleSoreness)
            }
        }
        if postLowerSoreness.count >= 2 {
            let avg = Double(postLowerSoreness.reduce(0, +)) / Double(postLowerSoreness.count)
            if avg >= 6.5 {
                insights.append(
                    Insight(
                        title: "Lower-body hangover",
                        message: "Soreness averages \(String(format: "%.1f", avg))/10 the day after lower-body sessions. Soften volume or add extra mobility.",
                        severity: .warning,
                        icon: "figure.strengthtraining.traditional"
                    )
                )
            }
        }

        // Best recovery window weekdays
        if entries.count >= 5 {
            var bucket: [Int: [Double]] = [:]
            for entry in entries {
                let weekday = calendar.component(.weekday, from: entry.date)
                bucket[weekday, default: []].append(entry.recoveryIndex)
            }
            let averages = bucket.compactMap { day, values -> (Int, Double)? in
                guard values.count >= 2 else { return nil }
                return (day, values.reduce(0, +) / Double(values.count))
            }
            if let best = averages.max(by: { $0.1 < $1.1 }),
               let second = averages.sorted(by: { $0.1 > $1.1 }).dropFirst().first {
                insights.append(
                    Insight(
                        title: "Best recovery window",
                        message: "Your strongest days tend to be \(weekdayName(best.0))–\(weekdayName(second.0)) (avg \(Int(best.1))% readiness). Plan quality sessions there.",
                        severity: .positive,
                        icon: "calendar"
                    )
                )
            }
        }

        // Injury healing progress
        let healing = injuries.filter { !$0.isActive || $0.painTrendDelta < 0 }
        if let improving = injuries.first(where: { $0.isActive && $0.painTrendDelta <= -2 }) {
            insights.append(
                Insight(
                    title: "\(improving.bodyPart.rawValue) improving",
                    message: "Pain trend is down \(abs(improving.painTrendDelta)) points recently. Keep loading cautious and consistent.",
                    severity: .positive,
                    icon: "heart.fill"
                )
            )
        } else if healing.isEmpty, injuries.contains(where: \.isActive) {
            insights.append(
                Insight(
                    title: "Watch active injuries",
                    message: "Pain is not trending down yet. Favor limit/avoid zones until pain eases 2+ points.",
                    severity: .warning,
                    icon: "cross.case.fill"
                )
            )
        }

        // Protocol adherence
        let progresses = recoveryEngine.getProtocolProgressList().suffix(5)
        if progresses.count >= 3 {
            let avg = progresses.map(\.completionRatio).reduce(0, +) / Double(progresses.count)
            if avg >= 0.75 {
                insights.append(
                    Insight(
                        title: "Protocol habit forming",
                        message: "You completed ~\(Int(avg * 100))% of recovery tasks recently. That bonus is feeding next-day readiness.",
                        severity: .positive,
                        icon: "checkmark.seal.fill"
                    )
                )
            } else if avg < 0.4 {
                insights.append(
                    Insight(
                        title: "Protocol gap",
                        message: "Recovery checklists are rarely finished. Completing 75%+ unlocks a readiness bonus next day.",
                        severity: .neutral,
                        icon: "list.bullet.clipboard"
                    )
                )
            }
        }

        // Red flag: high RPE + worsened pain
        let risky = sessions.filter { ($0.rpe ?? 0) >= 8 && !$0.worsenedBodyParts.isEmpty }
        if risky.count >= 2 {
            insights.append(
                Insight(
                    title: "High-cost sessions",
                    message: "\(risky.count) hard sessions ended with worse pain. Cap RPE and avoid aggravated zones on decision days marked Limit/Avoid.",
                    severity: .warning,
                    icon: "exclamationmark.triangle.fill"
                )
            )
        }

        if insights.isEmpty {
            insights.append(
                Insight(
                    title: "Keep logging",
                    message: "Add a few more condition checks, session intents, and post-checks to unlock personalized explanations.",
                    severity: .neutral,
                    icon: "sparkles"
                )
            )
        }

        return insights
    }

    // MARK: - Soft-load week plan (extra differentiator)

    func softLoadWeekPlan(from date: Date = Date()) -> [SoftLoadDayPlan] {
        let calendar = Calendar.current
        let decision = makeTodayDecision(date: date)
        var plan: [SoftLoadDayPlan] = []

        for offset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: date)) else { continue }
            let weekday = calendar.component(.weekday, from: day)
            let entry = recoveryEngine.getEntry(for: day)
            let dayDecision = entry == nil && offset > 0
                ? projectedDecision(base: decision, weekday: weekday, offset: offset)
                : makeTodayDecision(date: day)

            plan.append(
                SoftLoadDayPlan(
                    date: day,
                    kind: dayDecision.kind,
                    focus: dayDecision.sessionType.rawValue,
                    loadPercent: dayDecision.recommendedLoadPercent,
                    note: offset == 0 ? "Today’s live decision" : "Projected — update after you log condition"
                )
            )
        }
        return plan
    }

    // MARK: - Private helpers

    private func loadStatus(for injury: Injury) -> BodyPartLoadStatus {
        let advice: LoadAdvice
        let message: String
        switch injury.painLevel {
        case 8...10:
            advice = .avoid
            message = "Do not load \(injury.bodyPart.rawValue) today."
        case 5...7:
            advice = .limit
            message = "Limit \(injury.bodyPart.rawValue) — pain-free range only."
        default:
            advice = .ok
            message = "\(injury.bodyPart.rawValue) can take light–moderate load if pain-free."
        }
        return BodyPartLoadStatus(
            bodyPart: injury.bodyPart,
            painLevel: injury.painLevel,
            advice: advice,
            message: message
        )
    }

    private func restrictedZones(from bodyLoad: [BodyPartLoadStatus]) -> [LoadZone] {
        var zones = Set<LoadZone>()
        for status in bodyLoad where status.advice != .ok {
            zones.insert(status.bodyPart.loadZone)
        }
        return LoadZone.allCases.filter { zones.contains($0) }
    }

    private func classify(
        readiness: Double,
        restricted: [LoadZone],
        bodyLoad: [BodyPartLoadStatus],
        entry: RecoveryEntry?
    ) -> (TrainingDecisionKind, Int, SuggestedSessionType) {
        let hasAvoid = bodyLoad.contains { $0.advice == .avoid }
        let blocksLower = restricted.contains(.lower)
        let blocksUpper = restricted.contains(.upper)
        let blocksCore = restricted.contains(.core)

        if readiness < 35 || (entry?.fatigue ?? 0) >= 9 || hasAvoid && readiness < 55 {
            return (.rest, 0, .restDay)
        }

        if readiness < 55 || (entry?.muscleSoreness ?? 0) >= 8 {
            return (.activeRecovery, 30, .mobility)
        }

        if readiness < 72 || !restricted.isEmpty {
            let session: SuggestedSessionType
            if blocksLower && !blocksUpper {
                session = .upperOnly
            } else if blocksUpper && !blocksLower {
                session = .lowerOnly
            } else if blocksCore || (blocksLower && blocksUpper) {
                session = .zone2
            } else {
                session = .zone2
            }
            return (.trainEasy, 55, session)
        }

        if blocksLower {
            return (.trainHard, 85, .upperOnly)
        }
        if blocksUpper {
            return (.trainHard, 85, .lowerOnly)
        }
        return (.trainHard, 95, .fullIntensity)
    }

    private func projectedDecision(base: TrainingDecision, weekday: Int, offset: Int) -> TrainingDecision {
        // Alternate harder quality days mid-week when baseline is healthy.
        var kind = base.kind
        var load = max(base.recommendedLoadPercent - offset * 5, 20)
        var session = base.sessionType

        if base.kind == .trainHard || base.kind == .trainEasy {
            if weekday == 1 || weekday == 7 { // Sun / Sat
                kind = .activeRecovery
                load = 35
                session = .mobility
            } else if offset == 2 {
                kind = .trainEasy
                load = 60
                session = .zone2
            }
        }

        return TrainingDecision(
            kind: kind,
            readinessScore: base.readinessScore,
            baseRecoveryIndex: base.baseRecoveryIndex,
            injuryPenalty: base.injuryPenalty,
            protocolBonus: 0,
            recommendedLoadPercent: load,
            sessionType: session,
            restrictedZones: base.restrictedZones,
            reasons: base.reasons,
            bodyLoad: base.bodyLoad,
            summary: "Projected plan day",
            createdAt: Date()
        )
    }

    private func weekdayName(_ weekday: Int) -> String {
        switch weekday {
        case 1: return "Sun"
        case 2: return "Mon"
        case 3: return "Tue"
        case 4: return "Wed"
        case 5: return "Thu"
        case 6: return "Fri"
        case 7: return "Sat"
        default: return "Day"
        }
    }
}

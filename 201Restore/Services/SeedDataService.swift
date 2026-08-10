import Foundation

final class SeedDataService {
    private let engine: RecoveryEngine
    private let calendar = Calendar.current

    init(engine: RecoveryEngine) {
        self.engine = engine
    }

    static var hasLoadedSampleData: Bool {
        UserDefaults.standard.bool(forKey: StorageKeys.sampleDataLoaded)
    }

    /// Seeds only when the app has no recovery history yet.
    @discardableResult
    func seedIfEmpty() -> Bool {
        guard engine.getEntries().isEmpty else { return false }
        loadSampleData(replaceExisting: false)
        return true
    }

    func loadSampleData(replaceExisting: Bool = true) {
        if replaceExisting {
            engine.clearAllData()
        }

        let today = calendar.startOfDay(for: Date())
        let calculator = RecoveryEngine()
        var entries: [RecoveryEntry] = []
        var sessions: [SessionLog] = []
        var protocols: [DailyProtocolProgress] = []
        var journal: [DecisionJournalEntry] = []

        let profiles: [(fatigue: Int, soreness: Int, sleep: Int, mood: Int, energy: Int, intent: SessionIntent?, followed: Bool, protocolDone: Bool)] = [
            (7, 8, 4, 4, 3, .legDay, false, true),
            (6, 7, 5, 5, 4, .mobility, true, true),
            (5, 5, 7, 6, 6, .upperDay, true, false),
            (4, 4, 8, 7, 7, .conditioning, true, true),
            (8, 6, 3, 3, 3, .rest, true, true),
            (5, 5, 6, 6, 5, .longRun, false, true),
            (4, 3, 8, 8, 8, .fullBody, true, true),
            (6, 6, 5, 5, 5, .legDay, true, false),
            (5, 7, 6, 6, 5, .mobility, true, true),
            (3, 3, 9, 8, 9, .upperDay, true, true),
            (4, 4, 7, 7, 7, .conditioning, true, true),
            (5, 5, 7, 6, 6, .fullBody, true, true)
        ]

        for (offsetFromEnd, profile) in profiles.enumerated() {
            let daysBack = profiles.count - 1 - offsetFromEnd
            guard let date = calendar.date(byAdding: .day, value: -daysBack, to: today) else { continue }

            let index = calculator.calculateRecoveryIndex(
                fatigue: profile.fatigue,
                soreness: profile.soreness,
                sleep: profile.sleep,
                mood: profile.mood,
                energy: profile.energy
            )

            entries.append(
                RecoveryEntry(
                    id: UUID(),
                    date: date,
                    fatigue: profile.fatigue,
                    muscleSoreness: profile.soreness,
                    sleepQuality: profile.sleep,
                    mood: profile.mood,
                    energy: profile.energy,
                    notes: daysBack == 0 ? "Demo day — explore the coaching loop." : nil,
                    recoveryIndex: index,
                    createdAt: date
                )
            )

            if let intent = profile.intent {
                let completed = daysBack > 0
                sessions.append(
                    SessionLog(
                        id: UUID(),
                        date: date,
                        intent: intent,
                        intentNotes: nil,
                        isCompleted: completed,
                        rpe: completed ? (5 + (daysBack % 4)) : nil,
                        painAfterNotes: nil,
                        worsenedBodyParts: profile.soreness >= 7 && intent.involvesLower ? [.knee] : [],
                        followedDecision: profile.followed,
                        actualDecisionKind: profile.followed ? nil : .trainHard,
                        createdAt: date,
                        updatedAt: date
                    )
                )
            }

            let level = RecoveryLevel.from(index: index)
            let items = ProtocolLibrary.items(
                for: level,
                hasActiveInjury: true,
                sleep: profile.sleep,
                soreness: profile.soreness,
                bodyParts: [.knee]
            )
            let ids = items.map(\.id)
            let doneCount = profile.protocolDone ? max(Int((Double(ids.count) * 0.8).rounded()), 1) : max(ids.count / 3, 0)
            protocols.append(
                DailyProtocolProgress(
                    dayKey: AppDateFormatters.dayKey(for: date),
                    date: date,
                    completedItemIds: Array(ids.prefix(doneCount)),
                    itemIds: ids
                )
            )

            let kind: TrainingDecisionKind
            switch index {
            case 80...: kind = .trainHard
            case 60..<80: kind = .trainEasy
            case 35..<60: kind = .activeRecovery
            default: kind = .rest
            }
            journal.append(
                DecisionJournalEntry(
                    id: UUID(),
                    date: date,
                    kind: kind,
                    readinessScore: index,
                    followed: profile.followed,
                    note: profile.intent?.rawValue
                )
            )
        }

        let storage = UserDefaultsStorageService()
        storage.save(entries, forKey: StorageKeys.recoveryEntries)

        let kneeHistory: [PainSample] = (0..<8).compactMap { i -> PainSample? in
            guard let d = calendar.date(byAdding: .day, value: -(7 - i), to: today) else { return nil }
            return PainSample(date: d, level: max(3, 7 - i / 2))
        }

        let shoulderHistory: [PainSample] = (0..<5).compactMap { i -> PainSample? in
            guard let d = calendar.date(byAdding: .day, value: -(4 - i), to: today) else { return nil }
            return PainSample(date: d, level: 4)
        }

        let injuries = [
            Injury(
                id: UUID(),
                bodyPart: .knee,
                painLevel: kneeHistory.last?.level ?? 5,
                notes: "Demo: mild patellar irritation after leg days.",
                date: calendar.date(byAdding: .day, value: -10, to: today) ?? today,
                isActive: true,
                recoveryDate: nil,
                painHistory: kneeHistory
            ),
            Injury(
                id: UUID(),
                bodyPart: .shoulder,
                painLevel: 4,
                notes: "Demo: lingering from overhead work.",
                date: calendar.date(byAdding: .day, value: -5, to: today) ?? today,
                isActive: true,
                recoveryDate: nil,
                painHistory: shoulderHistory
            )
        ]
        storage.save(injuries, forKey: StorageKeys.injuries)
        storage.save(sessions, forKey: StorageKeys.sessionLogs)
        storage.save(protocols, forKey: StorageKeys.protocolProgress)
        storage.save(journal, forKey: StorageKeys.decisionJournal)

        engine.updateStats()
        engine.recomputeRitualStreaks()
        UserDefaults.standard.set(true, forKey: StorageKeys.sampleDataLoaded)
    }
}

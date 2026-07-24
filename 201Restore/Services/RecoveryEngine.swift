import Foundation

final class RecoveryEngine {
    private let storageService: StorageServiceProtocol

    init(storageService: StorageServiceProtocol = UserDefaultsStorageService()) {
        self.storageService = storageService
    }

    // MARK: - Recovery Entries

    func getEntries() -> [RecoveryEntry] {
        storageService.load(forKey: StorageKeys.recoveryEntries)
    }

    func addEntry(_ entry: RecoveryEntry) {
        storageService.append(entry, forKey: StorageKeys.recoveryEntries)
        updateStats()
    }

    func updateEntry(_ entry: RecoveryEntry) {
        storageService.update(entry, forKey: StorageKeys.recoveryEntries)
        updateStats()
    }

    func deleteEntry(_ entry: RecoveryEntry) {
        var entries = getEntries()
        entries.removeAll { $0.id == entry.id }
        storageService.save(entries, forKey: StorageKeys.recoveryEntries)
        updateStats()
    }

    func getEntry(for date: Date) -> RecoveryEntry? {
        let calendar = Calendar.current
        return getEntries().first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    func getEntries(for date: Date) -> [RecoveryEntry] {
        let calendar = Calendar.current
        return getEntries().filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    func getTodayEntry() -> RecoveryEntry? {
        getEntry(for: Date())
    }

    func getLastSevenDays() -> [RecoveryEntry] {
        let calendar = Calendar.current
        let today = Date()
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: today) else {
            return []
        }
        return getEntries().filter { $0.date >= sevenDaysAgo && $0.date <= today }
    }

    // MARK: - Injuries

    func getInjuries() -> [Injury] {
        storageService.load(forKey: StorageKeys.injuries)
    }

    func addInjury(_ injury: Injury) {
        storageService.append(injury, forKey: StorageKeys.injuries)
        updateStats()
    }

    func updateInjury(_ injury: Injury) {
        storageService.update(injury, forKey: StorageKeys.injuries)
        updateStats()
    }

    func deleteInjury(_ injury: Injury) {
        var injuries = getInjuries()
        injuries.removeAll { $0.id == injury.id }
        storageService.save(injuries, forKey: StorageKeys.injuries)
        updateStats()
    }

    func getActiveInjuries() -> [Injury] {
        getInjuries().filter(\.isActive)
    }

    func healInjury(_ injury: Injury) {
        var updated = injury
        updated.isActive = false
        updated.recoveryDate = Date()
        updateInjury(updated)
    }

    // MARK: - Stats

    func updateStats() {
        let entries = getEntries()
        let injuries = getInjuries()

        let totalEntries = entries.count
        let totalInjuries = injuries.count
        let activeInjuries = injuries.filter(\.isActive).count

        var averageRecovery: Double = 0
        var bestRecovery: Double = 0
        var worstRecovery: Double = 100
        var averageSleep: Double = 0
        var averageFatigue: Double = 0
        var averageSoreness: Double = 0

        if !entries.isEmpty {
            averageRecovery = entries.reduce(0) { $0 + $1.recoveryIndex } / Double(entries.count)
            bestRecovery = entries.map(\.recoveryIndex).max() ?? 0
            worstRecovery = entries.map(\.recoveryIndex).min() ?? 100
            averageSleep = entries.reduce(0) { $0 + Double($1.sleepQuality) } / Double(entries.count)
            averageFatigue = entries.reduce(0) { $0 + Double($1.fatigue) } / Double(entries.count)
            averageSoreness = entries.reduce(0) { $0 + Double($1.muscleSoreness) } / Double(entries.count)
        } else {
            worstRecovery = 0
        }

        let (currentStreak, maxStreak) = calculateStreaks(from: entries)

        let stats = Stats(
            totalEntries: totalEntries,
            averageRecoveryIndex: averageRecovery,
            bestRecoveryIndex: bestRecovery,
            worstRecoveryIndex: worstRecovery,
            currentStreak: currentStreak,
            maxStreak: maxStreak,
            totalInjuries: totalInjuries,
            activeInjuries: activeInjuries,
            averageSleepQuality: averageSleep,
            averageFatigue: averageFatigue,
            averageSoreness: averageSoreness
        )

        storageService.saveObject(stats, forKey: StorageKeys.stats)
    }

    func getStats() -> Stats {
        storageService.loadObject(forKey: StorageKeys.stats) ?? .empty
    }

    // MARK: - Calculation

    func calculateRecoveryIndex(
        fatigue: Int,
        soreness: Int,
        sleep: Int,
        mood: Int,
        energy: Int
    ) -> Double {
        let fatigueScore = 10 - Double(fatigue)
        let sorenessScore = 10 - Double(soreness)
        let sleepScore = Double(sleep)
        let moodScore = Double(mood)
        let energyScore = Double(energy)
        let average = (fatigueScore + sorenessScore + sleepScore + moodScore + energyScore) / 5.0
        return average * 10
    }

    func makeRecoveryIndex(
        fatigue: Int,
        soreness: Int,
        sleep: Int,
        mood: Int,
        energy: Int
    ) -> RecoveryIndex {
        RecoveryIndex(
            value: calculateRecoveryIndex(
                fatigue: fatigue,
                soreness: soreness,
                sleep: sleep,
                mood: mood,
                energy: energy
            )
        )
    }

    func getRecoveryLevel(for index: Double) -> RecoveryLevel {
        RecoveryLevel.from(index: index)
    }

    func getRecommendation(for entry: RecoveryEntry) -> String {
        Recommendation.forEntry(entry).message
    }

    // MARK: - Sessions

    func getSessionLogs() -> [SessionLog] {
        storageService.load(forKey: StorageKeys.sessionLogs)
    }

    func getSession(for date: Date) -> SessionLog? {
        let calendar = Calendar.current
        return getSessionLogs().first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    func getTodaySession() -> SessionLog? {
        getSession(for: Date())
    }

    func saveSession(_ session: SessionLog) {
        var sessions = getSessionLogs()
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
        } else if let index = sessions.firstIndex(where: {
            Calendar.current.isDate($0.date, inSameDayAs: session.date)
        }) {
            var merged = session
            merged = SessionLog(
                id: sessions[index].id,
                date: session.date,
                intent: session.intent,
                intentNotes: session.intentNotes,
                isCompleted: session.isCompleted,
                rpe: session.rpe,
                painAfterNotes: session.painAfterNotes,
                worsenedBodyParts: session.worsenedBodyParts,
                followedDecision: session.followedDecision,
                actualDecisionKind: session.actualDecisionKind,
                createdAt: sessions[index].createdAt,
                updatedAt: Date()
            )
            sessions[index] = merged
        } else {
            sessions.append(session)
        }
        storageService.save(sessions, forKey: StorageKeys.sessionLogs)
        recomputeRitualStreaks()
    }

    // MARK: - Protocols

    func protocolItems(for date: Date = Date()) -> [ProtocolItem] {
        let entry = getEntry(for: date)
        let level = entry?.recoveryLevel ?? .medium
        return ProtocolLibrary.items(
            for: level,
            hasActiveInjury: !getActiveInjuries().isEmpty
        )
    }

    func getProtocolProgressList() -> [DailyProtocolProgress] {
        storageService.load(forKey: StorageKeys.protocolProgress)
            .sorted { $0.date < $1.date }
    }

    func getProtocolProgress(for date: Date = Date()) -> DailyProtocolProgress {
        let key = AppDateFormatters.dayKey(for: date)
        if let existing = getProtocolProgressList().first(where: { $0.dayKey == key }) {
            return existing
        }
        let items = protocolItems(for: date)
        return DailyProtocolProgress(
            dayKey: key,
            date: Calendar.current.startOfDay(for: date),
            completedItemIds: [],
            itemIds: items.map(\.id)
        )
    }

    func saveProtocolProgress(_ progress: DailyProtocolProgress) {
        var all = getProtocolProgressList()
        if let index = all.firstIndex(where: { $0.dayKey == progress.dayKey }) {
            all[index] = progress
        } else {
            all.append(progress)
        }
        storageService.save(all, forKey: StorageKeys.protocolProgress)
        recomputeRitualStreaks()
    }

    func toggleProtocolItem(_ itemId: String, on date: Date = Date()) {
        var progress = getProtocolProgress(for: date)
        let items = protocolItems(for: date)
        progress.itemIds = items.map(\.id)
        if let idx = progress.completedItemIds.firstIndex(of: itemId) {
            progress.completedItemIds.remove(at: idx)
        } else {
            progress.completedItemIds.append(itemId)
        }
        saveProtocolProgress(progress)
    }

    func yesterdayProtocolBonus(relativeTo date: Date = Date()) -> Double {
        guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: date) else { return 0 }
        let progress = getProtocolProgressList().first {
            $0.dayKey == AppDateFormatters.dayKey(for: yesterday)
        }
        guard let progress, progress.isMostlyComplete else { return 0 }
        return 5
    }

    // MARK: - Rituals & Journal

    func getRitualStreaks() -> RitualStreaks {
        storageService.loadObject(forKey: StorageKeys.ritualStreaks) ?? .empty
    }

    func getDecisionJournal() -> [DecisionJournalEntry] {
        storageService.load(forKey: StorageKeys.decisionJournal)
            .sorted { $0.date > $1.date }
    }

    func upsertDecisionJournal(_ entry: DecisionJournalEntry) {
        var all = getDecisionJournal()
        let calendar = Calendar.current
        if let index = all.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: entry.date) }) {
            all[index] = entry
        } else {
            all.append(entry)
        }
        storageService.save(all, forKey: StorageKeys.decisionJournal)
    }

    func recordTodayDecision(_ decision: TrainingDecision, followed: Bool? = nil) {
        let entry = DecisionJournalEntry(
            id: UUID(),
            date: Calendar.current.startOfDay(for: Date()),
            kind: decision.kind,
            readinessScore: decision.readinessScore,
            followed: followed,
            note: decision.sessionType.rawValue
        )
        upsertDecisionJournal(entry)
        recomputeRitualStreaks()
    }

    func recomputeRitualStreaks() {
        let calendar = Calendar.current
        let sessions = getSessionLogs().sorted { $0.date > $1.date }
        let protocols = getProtocolProgressList().sorted { $0.date > $1.date }
        let journal = getDecisionJournal()
        let injuries = getInjuries()

        // Rest day kept when decision was Rest and session intent is rest or no hard intent
        var restStreak = 0
        for dayOffset in 0..<30 {
            guard let day = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else { break }
            let journalEntry = journal.first { calendar.isDate($0.date, inSameDayAs: day) }
            guard journalEntry?.kind == .rest else { break }
            let session = getSession(for: day)
            let kept = session?.intent == .rest || session?.followedDecision == true || session == nil
            if kept {
                restStreak += 1
            } else {
                break
            }
        }

        // Injury care same-day streak: consecutive days with a pain sample recorded
        var injuryStreak = 0
        for dayOffset in 0..<30 {
            guard let day = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else { break }
            let logged = injuries.contains { injury in
                injury.painHistory.contains { calendar.isDate($0.date, inSameDayAs: day) }
                    || calendar.isDate(injury.date, inSameDayAs: day)
            }
            if logged {
                injuryStreak += 1
            } else {
                break
            }
        }

        var protocolStreak = 0
        for dayOffset in 0..<30 {
            guard let day = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else { break }
            let key = AppDateFormatters.dayKey(for: day)
            guard let progress = protocols.first(where: { $0.dayKey == key }), progress.isMostlyComplete else { break }
            protocolStreak += 1
        }

        var followedStreak = 0
        for dayOffset in 0..<30 {
            guard let day = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else { break }
            let session = getSession(for: day)
            if session?.followedDecision == true {
                followedStreak += 1
            } else {
                break
            }
        }

        let previous = getRitualStreaks()
        let streaks = RitualStreaks(
            restDayKept: restStreak,
            injuryLoggedSameDay: injuryStreak,
            protocolCompleted: protocolStreak,
            decisionFollowed: followedStreak,
            maxRestDayKept: max(previous.maxRestDayKept, restStreak),
            maxInjuryLoggedSameDay: max(previous.maxInjuryLoggedSameDay, injuryStreak),
            maxProtocolCompleted: max(previous.maxProtocolCompleted, protocolStreak),
            maxDecisionFollowed: max(previous.maxDecisionFollowed, followedStreak)
        )
        storageService.saveObject(streaks, forKey: StorageKeys.ritualStreaks)
    }

    func clearAllData() {
        storageService.delete(forKey: StorageKeys.recoveryEntries)
        storageService.delete(forKey: StorageKeys.injuries)
        storageService.delete(forKey: StorageKeys.stats)
        storageService.delete(forKey: StorageKeys.sessionLogs)
        storageService.delete(forKey: StorageKeys.protocolProgress)
        storageService.delete(forKey: StorageKeys.ritualStreaks)
        storageService.delete(forKey: StorageKeys.decisionJournal)
    }

    // MARK: - Private

    private func calculateStreaks(from entries: [RecoveryEntry]) -> (current: Int, max: Int) {
        guard !entries.isEmpty else { return (0, 0) }

        let calendar = Calendar.current
        let uniqueDays = Set(entries.map { calendar.startOfDay(for: $0.date) }).sorted(by: >)

        var maxStreak = 1
        var run = 1
        for index in 1..<uniqueDays.count {
            let previous = uniqueDays[index - 1]
            let current = uniqueDays[index]
            let days = calendar.dateComponents([.day], from: current, to: previous).day ?? 0
            if days == 1 {
                run += 1
                maxStreak = max(maxStreak, run)
            } else {
                run = 1
            }
        }

        var currentStreak = 0
        let today = calendar.startOfDay(for: Date())
        guard let first = uniqueDays.first else { return (0, maxStreak) }

        let gapFromToday = calendar.dateComponents([.day], from: first, to: today).day ?? 0
        guard gapFromToday <= 1 else { return (0, maxStreak) }

        currentStreak = 1
        for index in 1..<uniqueDays.count {
            let previous = uniqueDays[index - 1]
            let current = uniqueDays[index]
            let days = calendar.dateComponents([.day], from: current, to: previous).day ?? 0
            if days == 1 {
                currentStreak += 1
            } else {
                break
            }
        }

        return (currentStreak, max(maxStreak, currentStreak))
    }
}

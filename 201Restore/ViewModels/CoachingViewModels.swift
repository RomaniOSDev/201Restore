import SwiftUI
import Combine

@MainActor
final class DecisionViewModel: ObservableObject {
    @Published var decision: TrainingDecision
    @Published var followedToday: Bool?
    @Published var followComparison: FollowComparison

    private let recoveryEngine: RecoveryEngine
    private let coachingEngine: CoachingEngine
    private weak var coordinator: AppCoordinator?

    init(recoveryEngine: RecoveryEngine, coordinator: AppCoordinator) {
        self.recoveryEngine = recoveryEngine
        self.coachingEngine = CoachingEngine(recoveryEngine: recoveryEngine)
        self.coordinator = coordinator
        self.decision = CoachingEngine(recoveryEngine: recoveryEngine).makeTodayDecision()
        self.followedToday = recoveryEngine.getTodaySession()?.followedDecision
        self.followComparison = CoachingEngine(recoveryEngine: recoveryEngine).followComparison()
    }

    func reload() {
        decision = coachingEngine.makeTodayDecision()
        followedToday = recoveryEngine.getTodaySession()?.followedDecision
        followComparison = coachingEngine.followComparison()
        recoveryEngine.recordTodayDecision(decision, followed: followedToday)
    }

    func markFollowed(_ followed: Bool) {
        var session = recoveryEngine.getTodaySession() ?? .blank()
        session.followedDecision = followed
        session.actualDecisionKind = decision.kind
        session.updatedAt = Date()
        recoveryEngine.saveSession(session)
        recoveryEngine.recordTodayDecision(decision, followed: followed)
        followedToday = followed
        followComparison = coachingEngine.followComparison()
    }

    func goToProtocol() { coordinator?.navigateToProtocol() }
    func goToSession() { coordinator?.navigateToSession() }
    func goToBodyMap() { coordinator?.navigateToBodyMap() }
    func goToGuidedRecovery() { coordinator?.navigateToGuidedRecovery() }
    func goBack() { coordinator?.pop() }
}

@MainActor
final class SessionViewModel: ObservableObject {
    @Published var intent: SessionIntent = .fullBody
    @Published var intentNotes: String = ""
    @Published var rpe: Int = 5
    @Published var painAfterNotes: String = ""
    @Published var worsened: Set<BodyPart> = []
    @Published var followedDecision = true
    @Published var isCompleted = false
    @Published var conflictWarning: String?

    private let recoveryEngine: RecoveryEngine
    private let coachingEngine: CoachingEngine
    private weak var coordinator: AppCoordinator?
    private var sessionId: UUID = UUID()
    private var createdAt: Date = Date()

    var activeBodyParts: [BodyPart] {
        let actives = Set(recoveryEngine.getActiveInjuries().map(\.bodyPart))
        return BodyPart.allCases.filter { actives.contains($0) } + BodyPart.allCases.filter { !actives.contains($0) }
    }

    init(recoveryEngine: RecoveryEngine, coordinator: AppCoordinator) {
        self.recoveryEngine = recoveryEngine
        self.coachingEngine = CoachingEngine(recoveryEngine: recoveryEngine)
        self.coordinator = coordinator
        if let existing = recoveryEngine.getTodaySession() {
            sessionId = existing.id
            createdAt = existing.createdAt
            intent = existing.intent ?? .fullBody
            intentNotes = existing.intentNotes ?? ""
            rpe = existing.rpe ?? 5
            painAfterNotes = existing.painAfterNotes ?? ""
            worsened = Set(existing.worsenedBodyParts)
            followedDecision = existing.followedDecision ?? true
            isCompleted = existing.isCompleted
        }
        conflictWarning = coachingEngine.intentConflictWarning(for: intent)
    }

    func intentChanged() {
        conflictWarning = coachingEngine.intentConflictWarning(for: intent)
    }

    func toggleWorsened(_ part: BodyPart) {
        if worsened.contains(part) {
            worsened.remove(part)
        } else {
            worsened.insert(part)
        }
    }

    func saveIntent() {
        persist(completed: isCompleted)
        coordinator?.pop()
    }

    func savePostCheck() {
        persist(completed: true)
        coordinator?.pop()
    }

    private func persist(completed: Bool) {
        let decision = coachingEngine.makeTodayDecision()
        let log = SessionLog(
            id: sessionId,
            date: Date(),
            intent: intent,
            intentNotes: intentNotes.isEmpty ? nil : intentNotes,
            isCompleted: completed,
            rpe: completed ? rpe : nil,
            painAfterNotes: painAfterNotes.isEmpty ? nil : painAfterNotes,
            worsenedBodyParts: Array(worsened),
            followedDecision: followedDecision,
            actualDecisionKind: decision.kind,
            createdAt: createdAt,
            updatedAt: Date()
        )
        recoveryEngine.saveSession(log)
        recoveryEngine.recordTodayDecision(decision, followed: followedDecision)
    }

    func goBack() { coordinator?.pop() }
}

@MainActor
final class ProtocolViewModel: ObservableObject {
    @Published var items: [ProtocolItem] = []
    @Published var progress: DailyProtocolProgress
    @Published var decision: TrainingDecision
    @Published var activeTimerItemId: String?
    @Published var timerRemaining: Int = 0
    @Published var timerRunning = false

    private let recoveryEngine: RecoveryEngine
    private weak var coordinator: AppCoordinator?
    private var timer: Timer?

    var completionPercent: Int {
        Int((progress.completionRatio * 100).rounded())
    }

    var tomorrowBoostUnlocked: Bool {
        progress.isMostlyComplete
    }

    var timerLabel: String {
        let m = timerRemaining / 60
        let s = timerRemaining % 60
        return String(format: "%d:%02d", m, s)
    }

    init(recoveryEngine: RecoveryEngine, coordinator: AppCoordinator) {
        self.recoveryEngine = recoveryEngine
        self.coordinator = coordinator
        let items = recoveryEngine.protocolItems()
        self.items = items
        var progress = recoveryEngine.getProtocolProgress()
        progress.itemIds = items.map(\.id)
        self.progress = progress
        self.decision = CoachingEngine(recoveryEngine: recoveryEngine).makeTodayDecision()
    }

    func isDone(_ id: String) -> Bool {
        progress.completedItemIds.contains(id)
    }

    func toggle(_ id: String) {
        recoveryEngine.toggleProtocolItem(id)
        progress = recoveryEngine.getProtocolProgress()
        progress.itemIds = items.map(\.id)
    }

    func startTimer(for item: ProtocolItem) {
        timer?.invalidate()
        activeTimerItemId = item.id
        timerRemaining = item.timerSeconds
        timerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tickTimer()
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        timerRunning = false
    }

    private func tickTimer() {
        guard timerRemaining > 0 else {
            if let id = activeTimerItemId, !isDone(id) {
                toggle(id)
            }
            stopTimer()
            return
        }
        timerRemaining -= 1
    }

    func goToGuidedRecovery() { coordinator?.navigateToGuidedRecovery() }
    func goBack() {
        stopTimer()
        coordinator?.pop()
    }

    deinit {
        timer?.invalidate()
    }
}

@MainActor
final class InsightsViewModel: ObservableObject {
    @Published var insights: [Insight] = []
    @Published var rituals: RitualStreaks = .empty
    @Published var journal: [DecisionJournalEntry] = []
    @Published var followComparison: FollowComparison
    @Published var weeklyReport = ""
    @Published var showShare = false

    private let recoveryEngine: RecoveryEngine
    private let coachingEngine: CoachingEngine
    private weak var coordinator: AppCoordinator?

    init(recoveryEngine: RecoveryEngine, coordinator: AppCoordinator) {
        self.recoveryEngine = recoveryEngine
        self.coachingEngine = CoachingEngine(recoveryEngine: recoveryEngine)
        self.coordinator = coordinator
        self.followComparison = CoachingEngine(recoveryEngine: recoveryEngine).followComparison()
        reload()
    }

    func reload() {
        insights = coachingEngine.generateInsights()
        rituals = recoveryEngine.getRitualStreaks()
        journal = Array(recoveryEngine.getDecisionJournal().prefix(14))
        followComparison = coachingEngine.followComparison()
        weeklyReport = coachingEngine.weeklyReportText()
    }

    func shareWeeklyReport() {
        weeklyReport = coachingEngine.weeklyReportText()
        showShare = true
    }

    func goBack() { coordinator?.pop() }
}

@MainActor
final class BodyMapViewModel: ObservableObject {
    @Published var selected: BodyPart = .knee
    @Published var statuses: [BodyPart: BodyPartLoadStatus] = [:]
    @Published var activeInjuries: [Injury] = []
    @Published var clearances: [ActivityClearance] = []
    @Published var returnToPlay: [ReturnToPlayDay] = []

    private let recoveryEngine: RecoveryEngine
    private let coachingEngine: CoachingEngine
    private weak var coordinator: AppCoordinator?

    var selectedStatus: BodyPartLoadStatus {
        statuses[selected] ?? coachingEngine.canLoad(selected)
    }

    var selectedInjury: Injury? {
        activeInjuries.first { $0.bodyPart == selected }
    }

    init(recoveryEngine: RecoveryEngine, coordinator: AppCoordinator) {
        self.recoveryEngine = recoveryEngine
        self.coachingEngine = CoachingEngine(recoveryEngine: recoveryEngine)
        self.coordinator = coordinator
        reload()
    }

    func reload() {
        activeInjuries = recoveryEngine.getActiveInjuries()
        var map: [BodyPart: BodyPartLoadStatus] = [:]
        for part in BodyPart.allCases {
            map[part] = coachingEngine.canLoad(part)
        }
        statuses = map
        clearances = coachingEngine.activityClearances()
        if let injury = selectedInjury {
            returnToPlay = coachingEngine.returnToPlayPlan(for: injury)
        } else if let first = activeInjuries.first {
            returnToPlay = coachingEngine.returnToPlayPlan(for: first)
        } else {
            returnToPlay = []
        }
    }

    func select(_ part: BodyPart) {
        selected = part
        if let injury = selectedInjury {
            returnToPlay = coachingEngine.returnToPlayPlan(for: injury)
        }
    }

    func goToInjuryForm() {
        coordinator?.navigateToInjuryForm(injury: selectedInjury)
    }

    func goBack() { coordinator?.pop() }
}

@MainActor
final class WeeklyPlanViewModel: ObservableObject {
    @Published var days: [SoftLoadDayPlan] = []

    private let coachingEngine: CoachingEngine
    private weak var coordinator: AppCoordinator?

    init(recoveryEngine: RecoveryEngine, coordinator: AppCoordinator) {
        self.coachingEngine = CoachingEngine(recoveryEngine: recoveryEngine)
        self.coordinator = coordinator
        days = coachingEngine.softLoadWeekPlan()
    }

    func reload() {
        days = coachingEngine.softLoadWeekPlan()
    }

    func goBack() { coordinator?.pop() }
}

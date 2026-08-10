import SwiftUI
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var todayEntry: RecoveryEntry?
    @Published var stats: Stats
    @Published var recentEntries: [RecoveryEntry] = []
    @Published var activeInjuries: [Injury] = []
    @Published var todayDecision: TrainingDecision?
    @Published var protocolPercent: Int = 0
    @Published var rituals: RitualStreaks = .empty
    @Published var topInsight: Insight?
    @Published var todaySession: SessionLog?
    @Published var workflowSteps: [DailyWorkflowStep] = []
    @Published var protocolBonusPreview: Int = 0

    private let recoveryEngine: RecoveryEngine
    private let coachingEngine: CoachingEngine
    private let seedService: SeedDataService
    private weak var coordinator: AppCoordinator?

    var hasTodayEntry: Bool { todayEntry != nil }

    var workflowCompletedCount: Int {
        workflowSteps.filter(\.isComplete).count
    }

    var workflowTotalCount: Int { max(workflowSteps.count, 1) }

    var recommendation: String {
        todayDecision?.summary ?? "Log today's condition to unlock a training decision"
    }

    init(recoveryEngine: RecoveryEngine, coordinator: AppCoordinator) {
        self.recoveryEngine = recoveryEngine
        self.coachingEngine = CoachingEngine(recoveryEngine: recoveryEngine)
        self.seedService = SeedDataService(engine: recoveryEngine)
        self.coordinator = coordinator
        self.stats = recoveryEngine.getStats()
        seedService.seedIfEmpty()
        loadData()
    }

    func loadData() {
        todayEntry = recoveryEngine.getTodayEntry()
        recentEntries = Array(
            recoveryEngine.getLastSevenDays()
                .sorted { $0.date > $1.date }
                .prefix(5)
        )
        activeInjuries = recoveryEngine.getActiveInjuries()
        stats = recoveryEngine.getStats()
        let decision = coachingEngine.makeTodayDecision()
        todayDecision = decision
        recoveryEngine.recordTodayDecision(decision, followed: recoveryEngine.getTodaySession()?.followedDecision)
        let progress = recoveryEngine.getProtocolProgress()
        protocolPercent = Int((progress.completionRatio * 100).rounded())
        protocolBonusPreview = progress.isMostlyComplete ? 5 : 0
        rituals = recoveryEngine.getRitualStreaks()
        topInsight = coachingEngine.generateInsights().first
        todaySession = recoveryEngine.getTodaySession()
        workflowSteps = coachingEngine.dailyWorkflowSteps()
    }

    func openWorkflow(_ step: DailyWorkflowStep) {
        switch step.kind {
        case .logCondition:
            if let todayEntry {
                coordinator?.navigateToEntryForm(entry: todayEntry)
            } else {
                coordinator?.navigateToEntryForm()
            }
        case .seeDecision:
            coordinator?.navigateToDecision()
        case .confirmIntent:
            coordinator?.navigateToSession()
        case .doProtocol:
            coordinator?.navigateToProtocol()
        case .postCheck:
            coordinator?.navigateToSession()
        }
    }

    func addEntry() { coordinator?.navigateToEntryForm() }
    func editEntry() { coordinator?.navigateToEntryForm(entry: todayEntry) }
    func goToCalendar() { coordinator?.navigateToCalendar() }
    func goToInjuries() { coordinator?.navigateToInjuries() }
    func goToStatistics() { coordinator?.navigateToStatistics() }
    func goToSettings() { coordinator?.navigateToSettings() }
    func goToDecision() { coordinator?.navigateToDecision() }
    func goToSession() { coordinator?.navigateToSession() }
    func goToProtocol() { coordinator?.navigateToProtocol() }
    func goToInsights() { coordinator?.navigateToInsights() }
    func goToBodyMap() { coordinator?.navigateToBodyMap() }
    func goToWeeklyPlan() { coordinator?.navigateToWeeklyPlan() }
    func goToGuidedRecovery() { coordinator?.navigateToGuidedRecovery() }
}

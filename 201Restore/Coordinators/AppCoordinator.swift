import SwiftUI
import Combine

enum AppRoute: Hashable {
    case entryForm(RecoveryEntry?)
    case calendar
    case injuries
    case injuryForm(Injury?)
    case statistics
    case settings
    case decision
    case session
    case protocolChecklist
    case insights
    case bodyMap
    case weeklyPlan
    case guidedRecovery
}

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var path = NavigationPath()

    let recoveryEngine: RecoveryEngine
    private var cachedHomeViewModel: HomeViewModel?

    init(recoveryEngine: RecoveryEngine = RecoveryEngine()) {
        self.recoveryEngine = recoveryEngine
    }

    var homeViewModel: HomeViewModel {
        if let cachedHomeViewModel {
            return cachedHomeViewModel
        }
        let viewModel = HomeViewModel(recoveryEngine: recoveryEngine, coordinator: self)
        cachedHomeViewModel = viewModel
        return viewModel
    }

    func start() -> HomeView {
        HomeView(viewModel: homeViewModel)
    }

    func navigateToEntryForm(entry: RecoveryEntry? = nil) {
        path.append(AppRoute.entryForm(entry))
    }

    func navigateToCalendar() {
        path.append(AppRoute.calendar)
    }

    func navigateToInjuries() {
        path.append(AppRoute.injuries)
    }

    func navigateToInjuryForm(injury: Injury? = nil) {
        path.append(AppRoute.injuryForm(injury))
    }

    func navigateToStatistics() {
        path.append(AppRoute.statistics)
    }

    func navigateToSettings() {
        path.append(AppRoute.settings)
    }

    func navigateToDecision() {
        path.append(AppRoute.decision)
    }

    func navigateToSession() {
        path.append(AppRoute.session)
    }

    func navigateToProtocol() {
        path.append(AppRoute.protocolChecklist)
    }

    func navigateToInsights() {
        path.append(AppRoute.insights)
    }

    func navigateToBodyMap() {
        path.append(AppRoute.bodyMap)
    }

    func navigateToWeeklyPlan() {
        path.append(AppRoute.weeklyPlan)
    }

    func navigateToGuidedRecovery() {
        path.append(AppRoute.guidedRecovery)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
        homeViewModel.loadData()
    }

    @ViewBuilder
    func destination(for route: AppRoute) -> some View {
        switch route {
        case .entryForm(let entry):
            EntryFormView(
                viewModel: EntryFormViewModel(
                    entry: entry,
                    recoveryEngine: recoveryEngine,
                    coordinator: self
                )
            )
        case .calendar:
            CalendarView(
                viewModel: CalendarViewModel(
                    recoveryEngine: recoveryEngine,
                    coordinator: self
                )
            )
        case .injuries:
            InjuryListView(
                viewModel: InjuryViewModel(
                    recoveryEngine: recoveryEngine,
                    coordinator: self
                )
            )
        case .injuryForm(let injury):
            InjuryFormView(
                viewModel: InjuryFormViewModel(
                    injury: injury,
                    recoveryEngine: recoveryEngine,
                    coordinator: self
                )
            )
        case .statistics:
            StatisticsView(
                viewModel: StatisticsViewModel(
                    recoveryEngine: recoveryEngine,
                    coordinator: self
                )
            )
        case .settings:
            SettingsView(
                viewModel: SettingsViewModel(
                    recoveryEngine: recoveryEngine,
                    coordinator: self
                )
            )
        case .decision:
            DecisionView(
                viewModel: DecisionViewModel(
                    recoveryEngine: recoveryEngine,
                    coordinator: self
                )
            )
        case .session:
            SessionView(
                viewModel: SessionViewModel(
                    recoveryEngine: recoveryEngine,
                    coordinator: self
                )
            )
        case .protocolChecklist:
            ProtocolView(
                viewModel: ProtocolViewModel(
                    recoveryEngine: recoveryEngine,
                    coordinator: self
                )
            )
        case .insights:
            InsightsView(
                viewModel: InsightsViewModel(
                    recoveryEngine: recoveryEngine,
                    coordinator: self
                )
            )
        case .bodyMap:
            BodyMapView(
                viewModel: BodyMapViewModel(
                    recoveryEngine: recoveryEngine,
                    coordinator: self
                )
            )
        case .weeklyPlan:
            WeeklyPlanView(
                viewModel: WeeklyPlanViewModel(
                    recoveryEngine: recoveryEngine,
                    coordinator: self
                )
            )
        case .guidedRecovery:
            GuidedRecoveryView(
                viewModel: GuidedRecoveryViewModel(coordinator: self)
            )
        }
    }
}

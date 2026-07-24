import SwiftUI
import Combine

@MainActor
final class InjuryViewModel: ObservableObject {
    @Published var injuries: [Injury] = []
    @Published var showActiveOnly = false
    @Published var searchText = ""

    private let recoveryEngine: RecoveryEngine
    private weak var coordinator: AppCoordinator?

    var filteredInjuries: [Injury] {
        var result = injuries
        if showActiveOnly {
            result = result.filter(\.isActive)
        }
        if !searchText.isEmpty {
            result = result.filter {
                $0.bodyPart.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
        return result.sorted { $0.date > $1.date }
    }

    var activeCount: Int {
        injuries.filter(\.isActive).count
    }

    init(recoveryEngine: RecoveryEngine, coordinator: AppCoordinator) {
        self.recoveryEngine = recoveryEngine
        self.coordinator = coordinator
        loadInjuries()
    }

    func loadInjuries() {
        injuries = recoveryEngine.getInjuries()
    }

    func deleteInjury(_ injury: Injury) {
        recoveryEngine.deleteInjury(injury)
        loadInjuries()
    }

    func healInjury(_ injury: Injury) {
        recoveryEngine.healInjury(injury)
        loadInjuries()
    }

    func goToInjuryForm(injury: Injury? = nil) {
        coordinator?.navigateToInjuryForm(injury: injury)
    }

    func goToBodyMap() {
        coordinator?.navigateToBodyMap()
    }

    func goBack() {
        coordinator?.pop()
    }
}

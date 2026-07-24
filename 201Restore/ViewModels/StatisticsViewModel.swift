import SwiftUI
import Combine

@MainActor
final class StatisticsViewModel: ObservableObject {
    @Published var stats: Stats
    @Published var entries: [RecoveryEntry] = []
    @Published var showShareSheet = false

    private let recoveryEngine: RecoveryEngine
    private weak var coordinator: AppCoordinator?

    var shareText: String {
        """
        Recovery Stats
        Entries: \(stats.totalEntries)
        Average index: \(Int(stats.averageRecoveryIndex))%
        Current streak: \(stats.currentStreak) days
        Active injuries: \(stats.activeInjuries)
        """
    }

    var weeklyData: [(String, Double)] {
        let calendar = Calendar.current
        let today = Date()
        var data: [(String, Double)] = []

        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let key = AppDateFormatters.shortDay.string(from: date)
            let dayEntries = entries.filter { calendar.isDate($0.date, inSameDayAs: date) }
            let avg = dayEntries.isEmpty
                ? 0
                : dayEntries.reduce(0) { $0 + $1.recoveryIndex } / Double(dayEntries.count)
            data.append((key, avg))
        }
        return data.reversed()
    }

    var recoveryLevelDistribution: [(RecoveryLevel, Int)] {
        var distribution: [RecoveryLevel: Int] = [:]
        for entry in entries {
            distribution[entry.recoveryLevel, default: 0] += 1
        }
        return RecoveryLevel.allCases.map { ($0, distribution[$0] ?? 0) }
    }

    init(recoveryEngine: RecoveryEngine, coordinator: AppCoordinator) {
        self.recoveryEngine = recoveryEngine
        self.coordinator = coordinator
        self.stats = recoveryEngine.getStats()
        loadData()
    }

    func loadData() {
        entries = recoveryEngine.getEntries()
        stats = recoveryEngine.getStats()
    }

    func goBack() {
        coordinator?.pop()
    }
}

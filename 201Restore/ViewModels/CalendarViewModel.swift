import SwiftUI
import Combine

@MainActor
final class CalendarViewModel: ObservableObject {
    @Published var entries: [RecoveryEntry] = []
    @Published var selectedDate: Date = Date()
    @Published var displayedMonth: Date = Date()

    private let recoveryEngine: RecoveryEngine
    private weak var coordinator: AppCoordinator?

    var selectedEntry: RecoveryEntry? {
        recoveryEngine.getEntry(for: selectedDate)
    }

    var monthEntries: [Date: RecoveryEntry] {
        var result: [Date: RecoveryEntry] = [:]
        let calendar = Calendar.current
        for entry in entries {
            result[calendar.startOfDay(for: entry.date)] = entry
        }
        return result
    }

    var daysInMonth: [Date?] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: displayedMonth),
              let startOfMonth = calendar.date(
                from: calendar.dateComponents([.year, .month], from: displayedMonth)
              ) else {
            return []
        }

        let weekday = calendar.component(.weekday, from: startOfMonth)
        // Convert to Monday-first offset (Mon=0 ... Sun=6)
        let mondayBased = (weekday + 5) % 7

        var days: [Date?] = Array(repeating: nil, count: mondayBased)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        return days
    }

    init(recoveryEngine: RecoveryEngine, coordinator: AppCoordinator) {
        self.recoveryEngine = recoveryEngine
        self.coordinator = coordinator
        loadEntries()
    }

    func loadEntries() {
        entries = recoveryEngine.getEntries()
    }

    func getColor(for date: Date) -> Color {
        guard let entry = monthEntries[Calendar.current.startOfDay(for: date)] else {
            return AppColors.card
        }
        return AppColors.recovery(entry.recoveryLevel)
    }

    func getEmoji(for date: Date) -> String {
        guard let entry = monthEntries[Calendar.current.startOfDay(for: date)] else {
            return "○"
        }
        return entry.recoveryLevel.emoji
    }

    func shiftMonth(by value: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }

    func goToEntryForm() {
        coordinator?.navigateToEntryForm(entry: selectedEntry)
    }

    func goBack() {
        coordinator?.pop()
    }
}

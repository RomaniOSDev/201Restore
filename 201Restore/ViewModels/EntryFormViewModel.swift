import SwiftUI
import Combine

@MainActor
final class EntryFormViewModel: ObservableObject {
    @Published var fatigue: Int = 5
    @Published var muscleSoreness: Int = 5
    @Published var sleepQuality: Int = 5
    @Published var mood: Int = 5
    @Published var energy: Int = 5
    @Published var notes: String = ""
    @Published var date: Date = Date()

    private let recoveryEngine: RecoveryEngine
    private weak var coordinator: AppCoordinator?
    private let editingEntry: RecoveryEntry?

    var isEditing: Bool { editingEntry != nil }

    var recoveryIndex: Double {
        recoveryEngine.calculateRecoveryIndex(
            fatigue: fatigue,
            soreness: muscleSoreness,
            sleep: sleepQuality,
            mood: mood,
            energy: energy
        )
    }

    var recoveryLevel: RecoveryLevel {
        recoveryEngine.getRecoveryLevel(for: recoveryIndex)
    }

    init(
        entry: RecoveryEntry? = nil,
        recoveryEngine: RecoveryEngine,
        coordinator: AppCoordinator
    ) {
        self.editingEntry = entry
        self.recoveryEngine = recoveryEngine
        self.coordinator = coordinator

        if let entry {
            fatigue = entry.fatigue
            muscleSoreness = entry.muscleSoreness
            sleepQuality = entry.sleepQuality
            mood = entry.mood
            energy = entry.energy
            notes = entry.notes ?? ""
            date = entry.date
        }
    }

    func saveEntry() {
        if isEditing, let entry = editingEntry {
            var updated = entry
            updated.fatigue = fatigue
            updated.muscleSoreness = muscleSoreness
            updated.sleepQuality = sleepQuality
            updated.mood = mood
            updated.energy = energy
            updated.notes = notes.isEmpty ? nil : notes
            updated.date = date
            updated.recoveryIndex = recoveryIndex
            recoveryEngine.updateEntry(updated)
        } else {
            let newEntry = RecoveryEntry(
                id: UUID(),
                date: date,
                fatigue: fatigue,
                muscleSoreness: muscleSoreness,
                sleepQuality: sleepQuality,
                mood: mood,
                energy: energy,
                notes: notes.isEmpty ? nil : notes,
                recoveryIndex: recoveryIndex,
                createdAt: Date()
            )
            recoveryEngine.addEntry(newEntry)
        }
        coordinator?.pop()
    }

    func cancel() {
        coordinator?.pop()
    }
}

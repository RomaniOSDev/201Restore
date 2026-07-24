import SwiftUI
import Combine

@MainActor
final class InjuryFormViewModel: ObservableObject {
    @Published var selectedBodyPart: BodyPart = .other
    @Published var painLevel: Int = 5
    @Published var notes: String = ""
    @Published var date: Date = Date()
    @Published var isActive: Bool = true

    private let recoveryEngine: RecoveryEngine
    private weak var coordinator: AppCoordinator?
    private let editingInjury: Injury?

    var isEditing: Bool { editingInjury != nil }

    init(
        injury: Injury? = nil,
        recoveryEngine: RecoveryEngine,
        coordinator: AppCoordinator
    ) {
        self.editingInjury = injury
        self.recoveryEngine = recoveryEngine
        self.coordinator = coordinator

        if let injury {
            selectedBodyPart = injury.bodyPart
            painLevel = injury.painLevel
            notes = injury.notes ?? ""
            date = injury.date
            isActive = injury.isActive
        }
    }

    func saveInjury() {
        if isEditing, let injury = editingInjury {
            var updated = injury
            updated.bodyPart = selectedBodyPart
            updated.recordPain(painLevel, on: date)
            updated.notes = notes.isEmpty ? nil : notes
            updated.date = date
            updated.isActive = isActive
            if !isActive && updated.recoveryDate == nil {
                updated.recoveryDate = Date()
            }
            recoveryEngine.updateInjury(updated)
        } else {
            let newInjury = Injury(
                id: UUID(),
                bodyPart: selectedBodyPart,
                painLevel: painLevel,
                notes: notes.isEmpty ? nil : notes,
                date: date,
                isActive: true,
                recoveryDate: nil
            )
            recoveryEngine.addInjury(newInjury)
        }
        coordinator?.pop()
    }

    func cancel() {
        coordinator?.pop()
    }
}

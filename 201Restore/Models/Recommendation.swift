import Foundation

struct Recommendation: Identifiable, Codable, Hashable {
    let id: UUID
    let level: RecoveryLevel
    let title: String
    let message: String
    let intensityHint: String

    init(level: RecoveryLevel) {
        self.id = UUID()
        self.level = level
        self.title = level.rawValue
        self.message = level.recommendation
        switch level {
        case .excellent:
            self.intensityHint = "100%"
        case .good:
            self.intensityHint = "70–80%"
        case .medium:
            self.intensityHint = "Light / Rest"
        case .poor:
            self.intensityHint = "Rest"
        }
    }

    static func forEntry(_ entry: RecoveryEntry) -> Recommendation {
        Recommendation(level: entry.recoveryLevel)
    }
}

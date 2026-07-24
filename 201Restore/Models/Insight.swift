import Foundation

enum InsightSeverity: String, Codable, Hashable {
    case positive
    case neutral
    case warning
}

struct Insight: Identifiable, Hashable {
    let id: UUID
    let title: String
    let message: String
    let severity: InsightSeverity
    let icon: String

    init(
        id: UUID = UUID(),
        title: String,
        message: String,
        severity: InsightSeverity,
        icon: String
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.severity = severity
        self.icon = icon
    }
}

struct RitualStreaks: Codable, Hashable {
    var restDayKept: Int
    var injuryLoggedSameDay: Int
    var protocolCompleted: Int
    var decisionFollowed: Int
    var maxRestDayKept: Int
    var maxInjuryLoggedSameDay: Int
    var maxProtocolCompleted: Int
    var maxDecisionFollowed: Int

    static let empty = RitualStreaks(
        restDayKept: 0,
        injuryLoggedSameDay: 0,
        protocolCompleted: 0,
        decisionFollowed: 0,
        maxRestDayKept: 0,
        maxInjuryLoggedSameDay: 0,
        maxProtocolCompleted: 0,
        maxDecisionFollowed: 0
    )
}

struct SoftLoadDayPlan: Identifiable, Hashable {
    var id: Date { date }
    let date: Date
    let kind: TrainingDecisionKind
    let focus: String
    let loadPercent: Int
    let note: String
}

struct DecisionJournalEntry: Identifiable, Codable, Hashable {
    let id: UUID
    var date: Date
    var kind: TrainingDecisionKind
    var readinessScore: Double
    var followed: Bool?
    var note: String?
}

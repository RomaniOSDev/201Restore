import Foundation

enum SessionIntent: String, CaseIterable, Codable, Hashable {
    case legDay = "Leg day"
    case upperDay = "Upper day"
    case fullBody = "Full body"
    case match = "Match / competition"
    case longRun = "Long run"
    case conditioning = "Conditioning"
    case mobility = "Mobility"
    case rest = "Planned rest"
    case other = "Other"

    var involvesLower: Bool {
        switch self {
        case .legDay, .fullBody, .match, .longRun, .conditioning: return true
        default: return false
        }
    }

    var involvesUpper: Bool {
        switch self {
        case .upperDay, .fullBody, .match, .conditioning: return true
        default: return false
        }
    }

    var stressedZones: [LoadZone] {
        var zones: [LoadZone] = []
        if involvesLower { zones.append(.lower) }
        if involvesUpper { zones.append(.upper) }
        if self == .fullBody || self == .match { zones.append(.core) }
        return zones
    }
}

struct SessionLog: Identifiable, Codable, Hashable {
    let id: UUID
    var date: Date
    var intent: SessionIntent?
    var intentNotes: String?
    var isCompleted: Bool
    var rpe: Int?
    var painAfterNotes: String?
    var worsenedBodyParts: [BodyPart]
    var followedDecision: Bool?
    var actualDecisionKind: TrainingDecisionKind?
    var createdAt: Date
    var updatedAt: Date

    static func blank(for date: Date = Date()) -> SessionLog {
        SessionLog(
            id: UUID(),
            date: date,
            intent: nil,
            intentNotes: nil,
            isCompleted: false,
            rpe: nil,
            painAfterNotes: nil,
            worsenedBodyParts: [],
            followedDecision: nil,
            actualDecisionKind: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

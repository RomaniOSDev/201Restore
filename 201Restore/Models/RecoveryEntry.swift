import Foundation

struct RecoveryEntry: Identifiable, Codable, Hashable {
    let id: UUID
    var date: Date
    var fatigue: Int
    var muscleSoreness: Int
    var sleepQuality: Int
    var mood: Int
    var energy: Int
    var notes: String?
    var recoveryIndex: Double
    var createdAt: Date

    var recoveryLevel: RecoveryLevel {
        RecoveryLevel.from(index: recoveryIndex)
    }
}

enum RecoveryLevel: String, CaseIterable, Codable, Hashable {
    case excellent = "Excellent"
    case good = "Good"
    case medium = "Average"
    case poor = "Poor"

    var colorHex: String {
        switch self {
        case .excellent: return "#4CAF50"
        case .good: return "#8BC34A"
        case .medium: return "#FFC107"
        case .poor: return "#F44336"
        }
    }

    var emoji: String {
        switch self {
        case .excellent: return "⚡️"
        case .good: return "✅"
        case .medium: return "⚠️"
        case .poor: return "❌"
        }
    }

    var recommendation: String {
        switch self {
        case .excellent: return "Excellent recovery! You can train at full intensity."
        case .good: return "Good condition. Aim for 70–80% training intensity."
        case .medium: return "Average recovery. Prefer a light session or rest."
        case .poor: return "Poor recovery. Rest today."
        }
    }

    static func from(index: Double) -> RecoveryLevel {
        switch index {
        case 0..<30: return .poor
        case 30..<60: return .medium
        case 60..<80: return .good
        case 80...100: return .excellent
        default: return .poor
        }
    }
}

import Foundation

enum TrainingDecisionKind: String, CaseIterable, Codable, Hashable {
    case trainHard = "Train Hard"
    case trainEasy = "Train Easy"
    case activeRecovery = "Active Recovery"
    case rest = "Rest"

    var emoji: String {
        switch self {
        case .trainHard: return "🔥"
        case .trainEasy: return "👌"
        case .activeRecovery: return "🧘"
        case .rest: return "🛑"
        }
    }

    var accentHex: String {
        switch self {
        case .trainHard: return "#4CAF50"
        case .trainEasy: return "#8BC34A"
        case .activeRecovery: return "#FFC107"
        case .rest: return "#F44336"
        }
    }
}

enum SuggestedSessionType: String, CaseIterable, Codable, Hashable {
    case fullIntensity = "Full intensity"
    case upperOnly = "Upper body only"
    case lowerOnly = "Lower body only"
    case zone2 = "Zone 2 aerobic"
    case mobility = "Mobility / flow"
    case skillsOnly = "Skills / technique"
    case restDay = "Full rest"
}

enum DecisionFactor: String, CaseIterable, Codable, Hashable {
    case sleep = "Sleep"
    case fatigue = "Fatigue"
    case soreness = "Soreness"
    case mood = "Mood"
    case energy = "Energy"
    case injury = "Injury"
    case protocolBoost = "Recovery protocol"
    case missingData = "Missing data"
}

struct DecisionReason: Identifiable, Codable, Hashable {
    let id: UUID
    let factor: DecisionFactor
    let detail: String
    let impact: Int

    init(id: UUID = UUID(), factor: DecisionFactor, detail: String, impact: Int) {
        self.id = id
        self.factor = factor
        self.detail = detail
        self.impact = impact
    }
}

struct BodyPartLoadStatus: Identifiable, Codable, Hashable {
    var id: BodyPart { bodyPart }
    let bodyPart: BodyPart
    let painLevel: Int
    let advice: LoadAdvice
    let message: String
}

struct TrainingDecision: Codable, Hashable {
    let kind: TrainingDecisionKind
    let readinessScore: Double
    let baseRecoveryIndex: Double
    let injuryPenalty: Double
    let protocolBonus: Double
    let recommendedLoadPercent: Int
    let sessionType: SuggestedSessionType
    let restrictedZones: [LoadZone]
    let reasons: [DecisionReason]
    let bodyLoad: [BodyPartLoadStatus]
    let summary: String
    let createdAt: Date
}

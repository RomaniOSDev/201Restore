import Foundation

struct Injury: Identifiable, Codable, Hashable {
    let id: UUID
    var bodyPart: BodyPart
    var painLevel: Int
    var notes: String?
    var date: Date
    var isActive: Bool
    var recoveryDate: Date?
    var painHistory: [PainSample]

    enum CodingKeys: String, CodingKey {
        case id, bodyPart, painLevel, notes, date, isActive, recoveryDate, painHistory
    }

    init(
        id: UUID,
        bodyPart: BodyPart,
        painLevel: Int,
        notes: String? = nil,
        date: Date,
        isActive: Bool,
        recoveryDate: Date? = nil,
        painHistory: [PainSample] = []
    ) {
        self.id = id
        self.bodyPart = bodyPart
        self.painLevel = painLevel
        self.notes = notes
        self.date = date
        self.isActive = isActive
        self.recoveryDate = recoveryDate
        self.painHistory = painHistory.isEmpty
            ? [PainSample(date: date, level: painLevel)]
            : painHistory
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        bodyPart = try container.decode(BodyPart.self, forKey: .bodyPart)
        painLevel = try container.decode(Int.self, forKey: .painLevel)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        date = try container.decode(Date.self, forKey: .date)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        recoveryDate = try container.decodeIfPresent(Date.self, forKey: .recoveryDate)
        let history = try container.decodeIfPresent([PainSample].self, forKey: .painHistory) ?? []
        painHistory = history.isEmpty ? [PainSample(date: date, level: painLevel)] : history
    }

    mutating func recordPain(_ level: Int, on date: Date = Date()) {
        painLevel = level
        let calendar = Calendar.current
        if let index = painHistory.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            painHistory[index] = PainSample(date: date, level: level)
        } else {
            painHistory.append(PainSample(date: date, level: level))
        }
        painHistory.sort { $0.date < $1.date }
    }

    var painTrendDelta: Int {
        guard painHistory.count >= 2 else { return 0 }
        let recent = painHistory.suffix(2)
        return (recent.last?.level ?? painLevel) - (recent.first?.level ?? painLevel)
    }
}

enum BodyPart: String, CaseIterable, Codable, Hashable {
    case neck = "Neck"
    case shoulder = "Shoulder"
    case elbow = "Elbow"
    case wrist = "Wrist"
    case back = "Back"
    case hip = "Hip"
    case knee = "Knee"
    case ankle = "Ankle"
    case foot = "Foot"
    case muscle = "Muscles"
    case other = "Other"

    var icon: String {
        switch self {
        case .neck: return "🧣"
        case .shoulder, .elbow, .muscle: return "💪"
        case .wrist: return "🤚"
        case .back: return "🔙"
        case .hip, .knee: return "🦵"
        case .ankle, .foot: return "🦶"
        case .other: return "📌"
        }
    }
}

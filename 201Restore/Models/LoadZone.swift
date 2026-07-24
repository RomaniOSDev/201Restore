import Foundation

struct PainSample: Codable, Hashable {
    let date: Date
    let level: Int
}

enum LoadZone: String, CaseIterable, Codable, Hashable {
    case upper = "Upper body"
    case lower = "Lower body"
    case core = "Core / back"
    case fullBody = "Full body"
}

enum LoadAdvice: String, Codable, Hashable {
    case ok = "OK to load"
    case limit = "Limit load"
    case avoid = "Avoid today"

    var colorHex: String {
        switch self {
        case .ok: return "#4CAF50"
        case .limit: return "#FFC107"
        case .avoid: return "#F44336"
        }
    }
}

extension BodyPart {
    var loadZone: LoadZone {
        switch self {
        case .neck, .shoulder, .elbow, .wrist: return .upper
        case .hip, .knee, .ankle, .foot: return .lower
        case .back: return .core
        case .muscle, .other: return .fullBody
        }
    }
}

import Foundation

enum ProtocolScenario: String, CaseIterable, Codable, Hashable {
    case poorSleep = "Poor sleep"
    case highSoreness = "High soreness"
    case highFatigue = "High fatigue"
    case kneePain = "Knee pain"
    case shoulderPain = "Shoulder / upper"
    case backPain = "Back pain"
    case general = "General recovery"
    case goodDay = "Good day maintenance"
}

struct ProtocolItem: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let detail: String
    let minutes: Int
    let timerSeconds: Int
    let scenarios: [ProtocolScenario]

    init(
        id: String,
        title: String,
        detail: String,
        minutes: Int,
        timerSeconds: Int = 0,
        scenarios: [ProtocolScenario] = [.general]
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.minutes = minutes
        self.timerSeconds = timerSeconds > 0 ? timerSeconds : minutes * 60
        self.scenarios = scenarios
    }

    var hasTimer: Bool { timerSeconds >= 60 }
}

struct DailyProtocolProgress: Identifiable, Codable, Hashable {
    var id: String { dayKey }
    var dayKey: String
    var date: Date
    var completedItemIds: [String]
    var itemIds: [String]

    var completionRatio: Double {
        guard !itemIds.isEmpty else { return 0 }
        let done = Set(completedItemIds).intersection(Set(itemIds)).count
        return Double(done) / Double(itemIds.count)
    }

    var isMostlyComplete: Bool {
        completionRatio >= 0.75
    }
}

enum ProtocolLibrary {
    static let catalog: [ProtocolItem] = [
        ProtocolItem(id: "hydrate", title: "Hydration check", detail: "Drink 400–500 ml water. Add electrolytes if you trained hard.", minutes: 2, timerSeconds: 120, scenarios: [.general, .goodDay, .highFatigue]),
        ProtocolItem(id: "protein", title: "Protein window", detail: "Eat 25–40g protein within 2 hours of training or as a recovery meal.", minutes: 5, timerSeconds: 0, scenarios: [.general, .goodDay, .highSoreness]),
        ProtocolItem(id: "sleep_wind", title: "Sleep wind-down", detail: "Screens off, dim lights, no caffeine. Prep for 7–9h sleep.", minutes: 20, timerSeconds: 1200, scenarios: [.poorSleep, .highFatigue, .general]),
        ProtocolItem(id: "nap20", title: "Power nap", detail: "Lie down 15–20 min. No deep-sleep guilt — stop if groggy.", minutes: 20, timerSeconds: 1200, scenarios: [.poorSleep, .highFatigue]),
        ProtocolItem(id: "mobility10", title: "Mobility flow 10 min", detail: "Hips, T-spine, ankles. Pain-free range only.", minutes: 10, timerSeconds: 600, scenarios: [.highSoreness, .general, .kneePain]),
        ProtocolItem(id: "mobility_hips", title: "Hip openers", detail: "90/90, couch stretch, glute bridge — 8–10 min.", minutes: 10, timerSeconds: 600, scenarios: [.highSoreness, .kneePain, .backPain]),
        ProtocolItem(id: "contrast", title: "Contrast shower", detail: "Warm 60s / cool 30s × 4 rounds. Finish cool.", minutes: 8, timerSeconds: 480, scenarios: [.highSoreness, .highFatigue]),
        ProtocolItem(id: "walk15", title: "Easy walk", detail: "Zone 1 walk outdoors. Nasal breathing if possible.", minutes: 15, timerSeconds: 900, scenarios: [.general, .highFatigue, .goodDay]),
        ProtocolItem(id: "breath5", title: "Box breathing", detail: "In 4 · hold 4 · out 4 · hold 4 for 5 minutes.", minutes: 5, timerSeconds: 300, scenarios: [.poorSleep, .highFatigue, .general]),
        ProtocolItem(id: "foam_roll", title: "Foam roll", detail: "Quads, calves, T-spine — 60–90s each side. Avoid bruised spots.", minutes: 10, timerSeconds: 600, scenarios: [.highSoreness]),
        ProtocolItem(id: "knee_care", title: "Knee care circuit", detail: "Terminal knee extensions, isometrics, pain-free range. No deep flexion under load.", minutes: 10, timerSeconds: 600, scenarios: [.kneePain]),
        ProtocolItem(id: "shoulder_care", title: "Shoulder care", detail: "Band external rotations, scap slides, light hangs if pain-free.", minutes: 10, timerSeconds: 600, scenarios: [.shoulderPain]),
        ProtocolItem(id: "back_care", title: "Back reset", detail: "Cat-cow, bird-dog, dead bug — slow and controlled.", minutes: 10, timerSeconds: 600, scenarios: [.backPain]),
        ProtocolItem(id: "ice_or_heat", title: "Ice or heat", detail: "Ice 10 min if flared today; heat if stiff and low pain.", minutes: 10, timerSeconds: 600, scenarios: [.kneePain, .shoulderPain, .backPain, .highSoreness]),
        ProtocolItem(id: "elevation", title: "Elevate & unload", detail: "Legs up wall 8–10 min. Breathe slowly.", minutes: 10, timerSeconds: 600, scenarios: [.kneePain, .highSoreness]),
        ProtocolItem(id: "carbs", title: "Carb refuel", detail: "Add slow carbs if readiness is low or sleep was poor.", minutes: 5, timerSeconds: 0, scenarios: [.poorSleep, .highFatigue, .goodDay]),
        ProtocolItem(id: "magnesium", title: "Evening magnesium note", detail: "If you use magnesium, take it with dinner. Skip if stomach is sensitive.", minutes: 1, timerSeconds: 0, scenarios: [.poorSleep]),
        ProtocolItem(id: "journal", title: "2-minute journal", detail: "Write: what limited me today + one win. Keeps patterns visible.", minutes: 2, timerSeconds: 120, scenarios: [.general, .goodDay]),
        ProtocolItem(id: "full_rest", title: "Protect rest", detail: "No intensity. Short walk only. Sleep is the workout.", minutes: 0, timerSeconds: 0, scenarios: [.poorSleep, .highFatigue]),
        ProtocolItem(id: "ankle_mob", title: "Ankle mobility", detail: "Knee-to-wall rocks and calf stretch — 6 min.", minutes: 6, timerSeconds: 360, scenarios: [.kneePain, .highSoreness]),
        ProtocolItem(id: "neck_reset", title: "Neck & traps reset", detail: "Gentle chin tucks and upper-trap stretch. No aggressive cracking.", minutes: 6, timerSeconds: 360, scenarios: [.shoulderPain, .general]),
        ProtocolItem(id: "sunlight", title: "Morning light", detail: "5–10 min outdoor light to anchor sleep tonight.", minutes: 8, timerSeconds: 480, scenarios: [.poorSleep, .goodDay]),
        ProtocolItem(id: "protein_carbs", title: "Recovery plate", detail: "Protein + carbs + colorful plants. Limit alcohol tonight.", minutes: 5, timerSeconds: 0, scenarios: [.highSoreness, .highFatigue]),
        ProtocolItem(id: "isometrics", title: "Pain-free isometrics", detail: "Hold light mid-range contractions 5×30s for the injured zone.", minutes: 8, timerSeconds: 480, scenarios: [.kneePain, .shoulderPain]),
        ProtocolItem(id: "cool_down", title: "Cooldown stretch", detail: "Hamstrings, hip flexors, chest opener — 8 min easy.", minutes: 8, timerSeconds: 480, scenarios: [.goodDay, .general]),
        ProtocolItem(id: "hydrate_extra", title: "Electrolyte top-up", detail: "If urine is dark or cramps hit, add electrolytes now.", minutes: 2, timerSeconds: 0, scenarios: [.highFatigue, .highSoreness]),
        ProtocolItem(id: "screen_curfew", title: "Screen curfew", detail: "No phone in bed. Charge outside the room tonight.", minutes: 1, timerSeconds: 0, scenarios: [.poorSleep]),
        ProtocolItem(id: "guided_mobility", title: "Guided mobility session", detail: "Follow the in-app 10-min guided recovery timer.", minutes: 10, timerSeconds: 600, scenarios: [.highSoreness, .general, .kneePain, .backPain])
    ]

    static func items(
        for level: RecoveryLevel,
        hasActiveInjury: Bool,
        sleep: Int? = nil,
        soreness: Int? = nil,
        fatigue: Int? = nil,
        bodyParts: [BodyPart] = []
    ) -> [ProtocolItem] {
        var wanted = Set<ProtocolScenario>()
        wanted.insert(.general)

        switch level {
        case .excellent, .good:
            wanted.insert(.goodDay)
        case .medium:
            wanted.insert(.highSoreness)
        case .poor:
            wanted.insert(.highFatigue)
            wanted.insert(.poorSleep)
        }

        if let sleep, sleep <= 4 { wanted.insert(.poorSleep) }
        if let soreness, soreness >= 7 { wanted.insert(.highSoreness) }
        if let fatigue, fatigue >= 7 { wanted.insert(.highFatigue) }

        for part in bodyParts {
            switch part.loadZone {
            case .lower: wanted.insert(.kneePain)
            case .upper: wanted.insert(.shoulderPain)
            case .core: wanted.insert(.backPain)
            case .fullBody: break
            }
            if part == .knee || part == .ankle || part == .hip { wanted.insert(.kneePain) }
            if part == .shoulder || part == .elbow || part == .neck { wanted.insert(.shoulderPain) }
            if part == .back { wanted.insert(.backPain) }
        }

        if hasActiveInjury && wanted.isDisjoint(with: [.kneePain, .shoulderPain, .backPain]) {
            wanted.insert(.kneePain)
        }

        var picked: [ProtocolItem] = []
        for scenario in wanted {
            let matches = catalog.filter { $0.scenarios.contains(scenario) }
            for item in matches where !picked.contains(where: { $0.id == item.id }) {
                picked.append(item)
                if picked.count >= 8 { break }
            }
            if picked.count >= 8 { break }
        }

        // Ensure guided mobility is available on tougher days
        if level == .medium || level == .poor || hasActiveInjury {
            if let guided = catalog.first(where: { $0.id == "guided_mobility" }),
               !picked.contains(where: { $0.id == guided.id }) {
                picked.insert(guided, at: min(1, picked.count))
            }
        }

        if picked.isEmpty {
            return Array(catalog.prefix(5))
        }
        return Array(picked.prefix(8))
    }
}

import Foundation

struct ProtocolItem: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let detail: String
    let minutes: Int
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
    static func items(for level: RecoveryLevel, hasActiveInjury: Bool) -> [ProtocolItem] {
        var items: [ProtocolItem] = []

        switch level {
        case .excellent, .good:
            items = [
                ProtocolItem(id: "hydrate", title: "Hydration check", detail: "Drink water and electrolytes after training.", minutes: 2),
                ProtocolItem(id: "protein", title: "Protein window", detail: "Eat a protein-rich meal within 2 hours.", minutes: 5),
                ProtocolItem(id: "sleep_wind", title: "Sleep wind-down", detail: "Screens off 30 min before bed.", minutes: 30)
            ]
        case .medium:
            items = [
                ProtocolItem(id: "mobility10", title: "Mobility 10 min", detail: "Hips, T-spine and ankles mobility flow.", minutes: 10),
                ProtocolItem(id: "contrast", title: "Contrast shower", detail: "Warm / cool cycles to boost recovery.", minutes: 8),
                ProtocolItem(id: "sleep_wind", title: "Sleep wind-down", detail: "Dim lights and avoid late caffeine.", minutes: 30),
                ProtocolItem(id: "hydrate", title: "Hydration check", detail: "Aim for clear/pale urine today.", minutes: 2),
                ProtocolItem(id: "protein", title: "Protein & carbs", detail: "Support tissue repair with a balanced meal.", minutes: 5)
            ]
        case .poor:
            items = [
                ProtocolItem(id: "full_rest", title: "Protect rest", detail: "Skip intensity. Keep walking light only.", minutes: 0),
                ProtocolItem(id: "mobility10", title: "Gentle mobility", detail: "Pain-free range only, 8–10 minutes.", minutes: 10),
                ProtocolItem(id: "nap_or_sleep", title: "Extra sleep", detail: "Add 20–40 min nap or earlier bedtime.", minutes: 30),
                ProtocolItem(id: "contrast", title: "Contrast shower", detail: "Finish cool to reduce inflammation feel.", minutes: 8),
                ProtocolItem(id: "hydrate", title: "Hydration + electrolytes", detail: "Replenish fluids deliberately.", minutes: 3),
                ProtocolItem(id: "protein", title: "Recovery meal", detail: "Protein + slow carbs, low alcohol.", minutes: 5)
            ]
        }

        if hasActiveInjury {
            items.append(
                ProtocolItem(
                    id: "injury_care",
                    title: "Injury care",
                    detail: "Ice/heat as needed, pain-free mobility, no aggravating moves.",
                    minutes: 10
                )
            )
        }

        return items
    }
}

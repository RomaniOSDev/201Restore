import Foundation

struct Stats: Codable, Hashable {
    var totalEntries: Int
    var averageRecoveryIndex: Double
    var bestRecoveryIndex: Double
    var worstRecoveryIndex: Double
    var currentStreak: Int
    var maxStreak: Int
    var totalInjuries: Int
    var activeInjuries: Int
    var averageSleepQuality: Double
    var averageFatigue: Double
    var averageSoreness: Double

    static let empty = Stats(
        totalEntries: 0,
        averageRecoveryIndex: 0,
        bestRecoveryIndex: 0,
        worstRecoveryIndex: 0,
        currentStreak: 0,
        maxStreak: 0,
        totalInjuries: 0,
        activeInjuries: 0,
        averageSleepQuality: 0,
        averageFatigue: 0,
        averageSoreness: 0
    )
}

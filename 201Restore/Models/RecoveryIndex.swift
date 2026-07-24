import Foundation

struct RecoveryIndex: Codable, Hashable {
    let value: Double
    let level: RecoveryLevel
    let calculatedAt: Date

    init(value: Double, calculatedAt: Date = Date()) {
        let clamped = min(max(value, 0), 100)
        self.value = clamped
        self.level = RecoveryLevel.from(index: clamped)
        self.calculatedAt = calculatedAt
    }

    var displayValue: String {
        "\(Int(value))%"
    }
}

import SwiftUI

enum AppColors {
    static let background = Color("AppBackground")
    static let surface = Color("AppSurface")
    static let primary = Color("AppPrimary")
    static let accent = Color("AppAccent")
    static let textPrimary = Color("AppTextPrimary")
    static let textSecondary = Color("AppTextSecondary")

    /// Cards / panels — same as surface
    static let card = surface

    static let recoveryGood = Color("RecoveryGood")
    static let recoveryMedium = Color("RecoveryMedium")
    static let recoveryPoor = Color("RecoveryPoor")
    static let recoveryExcellent = Color("RecoveryExcellent")

    static func recovery(_ level: RecoveryLevel) -> Color {
        switch level {
        case .excellent: return recoveryGood
        case .good: return recoveryExcellent
        case .medium: return recoveryMedium
        case .poor: return recoveryPoor
        }
    }
}

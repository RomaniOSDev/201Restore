import SwiftUI

struct RecoveryLevelBadge: View {
    let level: RecoveryLevel

    var body: some View {
        HStack(spacing: 6) {
            Text(level.emoji)
            Text(level.rawValue)
                .font(.caption.weight(.bold))
        }
        .foregroundStyle(AppColors.textPrimary)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            LinearGradient(
                colors: [
                    AppColors.recovery(level).opacity(0.28),
                    AppColors.recovery(level).opacity(0.12)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            Capsule()
                .stroke(AppColors.recovery(level).opacity(0.55), lineWidth: 1)
        )
        .clipShape(Capsule())
    }
}

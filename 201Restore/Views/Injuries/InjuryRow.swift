import SwiftUI

struct InjuryRow: View {
    let injury: Injury
    let onTap: () -> Void
    let onHeal: () -> Void
    let onDelete: () -> Void

    private var badgeTint: Color {
        if !injury.isActive { return AppColors.recoveryGood }
        if injury.painLevel >= 7 { return AppColors.recoveryPoor }
        if injury.painLevel >= 5 { return AppColors.recoveryMedium }
        return AppColors.accent
    }

    var body: some View {
        GlassCard(
            padding: 14,
            cornerRadius: 16,
            accent: injury.isActive ? AppColors.recoveryPoor : AppColors.recoveryGood
        ) {
            VStack(alignment: .leading, spacing: 12) {
                Button(action: onTap) {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(badgeTint.opacity(0.16))
                            Text(injury.bodyPart.icon)
                                .font(.title2)
                        }
                        .frame(width: 48, height: 48)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(injury.bodyPart.rawValue)
                                .font(.headline.weight(.bold))
                                .foregroundStyle(AppColors.textPrimary)
                            Text("\(injury.bodyPart.loadZone.rawValue) · since \(AppDateFormatters.dayMonth.string(from: injury.date))")
                                .font(.caption)
                                .foregroundStyle(AppColors.textSecondary)
                        }

                        Spacer()

                        Text(injury.isActive ? "Active" : "Healed")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(injury.isActive ? AppColors.recoveryPoor : AppColors.recoveryGood)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background((injury.isActive ? AppColors.recoveryPoor : AppColors.recoveryGood).opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
                .buttonStyle(.plain)

                SoftProgressBar(value: Double(injury.painLevel) / 10, tint: badgeTint, height: 7)

                HStack {
                    Text("Pain \(injury.painLevel)/10")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColors.textPrimary)
                    if injury.painTrendDelta != 0 {
                        Text(injury.painTrendDelta < 0 ? "Improving" : "Rising")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(injury.painTrendDelta < 0 ? AppColors.recoveryGood : AppColors.recoveryPoor)
                    }
                    Spacer()
                    if injury.isActive {
                        Button("Heal", action: onHeal)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppColors.recoveryGood)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(AppColors.recoveryGood.opacity(0.14))
                            .clipShape(Capsule())
                    }
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppColors.recoveryPoor.opacity(0.8))
                            .padding(8)
                            .background(AppColors.recoveryPoor.opacity(0.12))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

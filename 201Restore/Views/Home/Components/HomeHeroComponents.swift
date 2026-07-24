import SwiftUI

struct HomeHeroBanner: View {
    let readiness: Int
    let decisionTitle: String
    let onDecision: () -> Void
    let onAdd: () -> Void

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("HomeHero")
                .resizable()
                .interpolation(.medium)
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 210)
                .clipped()

            AppGradients.heroScrim

            // Top sheen for volume
            LinearGradient(
                colors: [Color.white.opacity(0.10), Color.clear],
                startPoint: .top,
                endPoint: .center
            )
            .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 10) {
                Text("TODAY")
                    .font(.caption2.weight(.bold))
                    .tracking(1.2)
                    .foregroundStyle(AppColors.primary)

                Text(decisionTitle)
                    .font(.title2.bold())
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text("Readiness \(readiness)% · Injury-aware coaching")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)

                SoftProgressBar(value: Double(readiness) / 100, tint: AppColors.accent, height: 6)
                    .frame(maxWidth: 180)

                HStack(spacing: 10) {
                    Button(action: onDecision) {
                        Text("Open Decision")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.black.opacity(0.85))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(AppGradients.actionFill(accent: AppColors.primary))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(PressableCardStyle())

                    Button(action: onAdd) {
                        Text("Log Condition")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppColors.textPrimary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(AppColors.card.opacity(0.88))
                            .overlay(Capsule().stroke(AppGradients.edgeSheen(accent: AppColors.primary), lineWidth: 1))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(PressableCardStyle())
                }
            }
            .padding(18)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 210)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(AppGradients.edgeSheen(accent: AppColors.primary), lineWidth: 1.2)
        )
        .depthShadow(.featured)
    }
}

struct ImageFeatureTile: View {
    let imageName: String
    let title: String
    let subtitle: String
    var tint: Color = AppColors.accent
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .bottom) {
                    Image(imageName)
                        .resizable()
                        .interpolation(.medium)
                        .scaledToFill()
                        .frame(height: 96)
                        .frame(maxWidth: .infinity)
                        .clipped()

                    LinearGradient(
                        colors: [Color.clear, AppColors.card],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 42)
                    .allowsHitTesting(false)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        colors: [AppColors.card, tint.opacity(0.08)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppGradients.edgeSheen(accent: tint), lineWidth: 1)
            )
            .depthShadow(.standard)
        }
        .buttonStyle(PressableCardStyle())
    }
}

struct HomeQuickActionImageButton: View {
    let systemIcon: String
    let title: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [tint.opacity(0.28), tint.opacity(0.10)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                    Circle()
                        .stroke(tint.opacity(0.25), lineWidth: 1)
                        .frame(width: 48, height: 48)
                    Image(systemName: systemIcon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(tint)
                }
                Text(title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(AppGradients.cardFill(accent: tint))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppGradients.edgeSheen(accent: tint), lineWidth: 1)
            )
            .depthShadow(.compact)
        }
        .buttonStyle(PressableCardStyle())
    }
}

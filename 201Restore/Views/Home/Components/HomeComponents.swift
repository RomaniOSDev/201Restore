import SwiftUI

struct StatsCard: View {
    let value: String
    let label: String
    let color: Color
    var icon: String? = nil

    var body: some View {
        MetricCell(value: value, label: label, tint: color, icon: icon)
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            GlassCard(padding: 12, cornerRadius: 16, accent: color) {
                VStack(spacing: 8) {
                    IconBadge(systemName: icon, tint: color, size: 36)
                    Text(title)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(AppColors.textPrimary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(PressableCardStyle())
    }
}

struct TodayStatusCard: View {
    let entry: RecoveryEntry
    let onEdit: () -> Void

    var body: some View {
        GlassCard(padding: 16, cornerRadius: 20, accent: AppColors.recovery(entry.recoveryLevel), depth: .featured) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Condition Today")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(AppColors.textPrimary)
                        Text("Manual check-in")
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    Spacer()
                    Button(action: onEdit) {
                        Label("Edit", systemImage: "pencil")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppColors.accent)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(AppColors.accent.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }

                HStack(spacing: 16) {
                    RecoveryCircleView(
                        index: entry.recoveryIndex,
                        size: 88,
                        level: entry.recoveryLevel
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        RecoveryLevelBadge(level: entry.recoveryLevel)
                        Text(entry.recoveryLevel.recommendation)
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    miniMetric("Fatigue", entry.fatigue, AppColors.recoveryPoor)
                    miniMetric("Soreness", entry.muscleSoreness, AppColors.recoveryMedium)
                    miniMetric("Sleep", entry.sleepQuality, AppColors.recoveryGood)
                    miniMetric("Energy", entry.energy, AppColors.accent)
                }
            }
        }
    }

    private func miniMetric(_ title: String, _ value: Int, _ tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(AppColors.textSecondary)
                Spacer()
                Text("\(value)/10")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
            }
            SoftProgressBar(value: Double(value) / 10, tint: tint, height: 6)
        }
        .padding(10)
        .background(AppColors.background.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct EmptyStateCard: View {
    let onAdd: () -> Void

    var body: some View {
        GlassCard(padding: 20, cornerRadius: 20, accent: AppColors.accent, depth: .featured) {
            VStack(spacing: 14) {
                IconBadge(systemName: "square.and.pencil", tint: AppColors.accent, size: 54)
                Text("No entry for today")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                Text("Log how you feel to unlock today’s training call.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)

                Button(action: onAdd) {
                    Text("Add Condition")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.black.opacity(0.85))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppGradients.actionFill(accent: AppColors.primary))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(PressableCardStyle())
            }
        }
    }
}

struct StatItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.textPrimary)
            Text(label)
                .font(.caption2)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct RecentEntryRow: View {
    let entry: RecoveryEntry
    var action: (() -> Void)? = nil

    var body: some View {
        AppListRowCell(
            leadingEmoji: entry.recoveryLevel.emoji,
            leadingIcon: nil,
            title: entry.recoveryLevel.rawValue,
            subtitle: "Index \(Int(entry.recoveryIndex))% · sleep \(entry.sleepQuality)/10",
            trailing: AppDateFormatters.dayMonth.string(from: entry.date),
            badge: "\(Int(entry.recoveryIndex))%",
            badgeTint: AppColors.recovery(entry.recoveryLevel),
            accent: AppColors.recovery(entry.recoveryLevel),
            action: action
        )
    }
}

struct TrainingDecisionCard: View {
    let decision: TrainingDecision
    let onOpen: () -> Void

    var body: some View {
        Button(action: onOpen) {
            GlassCard(padding: 16, cornerRadius: 20, accent: Color(hex: decision.kind.accentHex), depth: .featured) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Label("Today’s Call", systemImage: "target")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(AppColors.textPrimary)
                        Spacer()
                        Text("Open")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppColors.accent)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(AppColors.accent.opacity(0.14))
                            .clipShape(Capsule())
                    }

                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color(hex: decision.kind.accentHex).opacity(0.35),
                                            Color(hex: decision.kind.accentHex).opacity(0.08)
                                        ],
                                        center: .center,
                                        startRadius: 4,
                                        endRadius: 34
                                    )
                                )
                                .frame(width: 64, height: 64)
                            Text(decision.kind.emoji)
                                .font(.system(size: 30))
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(decision.kind.rawValue)
                                .font(.title3.bold())
                                .foregroundStyle(Color(hex: decision.kind.accentHex))
                            Text("\(decision.sessionType.rawValue)")
                                .font(.caption)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        Spacer()
                    }

                    HStack(spacing: 8) {
                        pill("\(Int(decision.readinessScore))% ready", AppColors.accent)
                        pill("\(decision.recommendedLoadPercent)% load", Color(hex: decision.kind.accentHex))
                    }

                    SoftProgressBar(
                        value: decision.readinessScore / 100,
                        tint: Color(hex: decision.kind.accentHex)
                    )

                    if let top = decision.reasons.first {
                        Text("Why: \(top.detail)")
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                            .lineLimit(2)
                    }

                    if !decision.restrictedZones.isEmpty {
                        Text("Restricted · " + decision.restrictedZones.map(\.rawValue).joined(separator: ", "))
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(AppColors.recoveryMedium)
                    }
                }
            }
        }
        .buttonStyle(PressableCardStyle())
    }

    private func pill(_ text: String, _ tint: Color) -> some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .foregroundStyle(tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(tint.opacity(0.14))
            .clipShape(Capsule())
    }
}

import SwiftUI

// MARK: - Metric / KPI cell

struct MetricCell: View {
    let value: String
    let label: String
    var tint: Color = AppColors.accent
    var icon: String? = nil

    var body: some View {
        GlassCard(padding: 12, cornerRadius: 16, accent: tint, depth: .compact) {
            VStack(alignment: .leading, spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(tint)
                }
                Text(value)
                    .font(.title3.bold())
                    .foregroundStyle(
                        LinearGradient(
                            colors: [tint, tint.opacity(0.75)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(label)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
    }
}

// MARK: - Navigation feature cell

struct FeatureNavCell: View {
    let icon: String
    let title: String
    let subtitle: String
    var tint: Color = AppColors.accent
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            GlassCard(padding: 14, cornerRadius: 16, accent: tint) {
                HStack(spacing: 12) {
                    IconBadge(systemName: icon, tint: tint, size: 40)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(AppColors.textPrimary)
                        Text(subtitle)
                            .font(.caption2)
                            .foregroundStyle(AppColors.textSecondary)
                            .lineLimit(2)
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColors.textSecondary.opacity(0.7))
                }
            }
        }
        .buttonStyle(PressableCardStyle())
    }
}

// MARK: - List row cell

struct AppListRowCell: View {
    let leadingEmoji: String?
    let leadingIcon: String?
    let title: String
    let subtitle: String
    var trailing: String? = nil
    var badge: String? = nil
    var badgeTint: Color = AppColors.accent
    var accent: Color = AppColors.accent
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            action?()
        } label: {
            GlassCard(padding: 14, cornerRadius: 16, accent: accent) {
                HStack(spacing: 12) {
                    leadingView

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppColors.textPrimary)
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                            .lineLimit(2)
                    }

                    Spacer(minLength: 4)

                    VStack(alignment: .trailing, spacing: 4) {
                        if let badge {
                            Text(badge)
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(badgeTint)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(badgeTint.opacity(0.15))
                                .clipShape(Capsule())
                        }
                        if let trailing {
                            Text(trailing)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                }
            }
        }
        .buttonStyle(PressableCardStyle())
        .disabled(action == nil)
    }

    @ViewBuilder
    private var leadingView: some View {
        if let leadingEmoji {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(accent.opacity(0.14))
                Text(leadingEmoji)
                    .font(.title3)
            }
            .frame(width: 44, height: 44)
        } else if let leadingIcon {
            IconBadge(systemName: leadingIcon, tint: accent, size: 44)
        }
    }
}

// MARK: - Insight cell

struct InsightCell: View {
    let insight: Insight
    var action: (() -> Void)? = nil

    private var tint: Color {
        switch insight.severity {
        case .positive: return AppColors.recoveryGood
        case .warning: return AppColors.recoveryPoor
        case .neutral: return AppColors.recoveryMedium
        }
    }

    var body: some View {
        Button {
            action?()
        } label: {
            GlassCard(padding: 14, cornerRadius: 16, accent: tint) {
                HStack(alignment: .top, spacing: 12) {
                    IconBadge(systemName: insight.icon, tint: tint, size: 40)
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(insight.title)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(AppColors.textPrimary)
                            Spacer()
                            Text(insight.severity == .warning ? "Watch" : insight.severity == .positive ? "Good" : "Note")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(tint)
                        }
                        Text(insight.message)
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .buttonStyle(PressableCardStyle())
        .disabled(action == nil)
    }
}

// MARK: - Decision reason cell

struct DecisionReasonCell: View {
    let reason: DecisionReason

    private var tint: Color {
        reason.impact >= 0 ? AppColors.recoveryGood : AppColors.recoveryPoor
    }

    var body: some View {
        GlassCard(padding: 12, cornerRadius: 14, accent: tint) {
            HStack(alignment: .top, spacing: 10) {
                ZStack {
                    Circle()
                        .fill(tint.opacity(0.18))
                        .frame(width: 28, height: 28)
                    Image(systemName: reason.impact >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(tint)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(reason.factor.rawValue)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppColors.textPrimary)
                    Text(reason.detail)
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                Text("\(reason.impact > 0 ? "+" : "")\(reason.impact)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(tint)
            }
        }
    }
}

// MARK: - Protocol checklist cell

struct ProtocolItemCell: View {
    let item: ProtocolItem
    let isDone: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            GlassCard(
                padding: 14,
                cornerRadius: 16,
                accent: isDone ? AppColors.recoveryGood : AppColors.accent
            ) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(isDone ? AppColors.recoveryGood : AppColors.textSecondary)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(AppColors.textPrimary)
                            .strikethrough(isDone, color: AppColors.textSecondary)
                        Text(item.detail)
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                        if item.minutes > 0 {
                            Label("\(item.minutes) min", systemImage: "clock")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(AppColors.accent)
                        }
                    }
                    Spacer(minLength: 0)
                }
            }
        }
        .buttonStyle(PressableCardStyle())
    }
}

// MARK: - Week plan cell

struct PlanDayCell: View {
    let day: SoftLoadDayPlan
    var isToday: Bool = false

    var body: some View {
        GlassCard(
            padding: 14,
            cornerRadius: 16,
            accent: Color(hex: day.kind.accentHex),
            depth: isToday ? .featured : .standard
        ) {
            HStack(alignment: .top, spacing: 12) {
                VStack(spacing: 6) {
                    Text(day.kind.emoji)
                        .font(.title2)
                    Text("\(day.loadPercent)%")
                        .font(.caption2.bold())
                        .foregroundStyle(Color(hex: day.kind.accentHex))
                }
                .frame(width: 52)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(AppDateFormatters.dayMonth.string(from: day.date))
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(AppColors.textPrimary)
                        if isToday {
                            Text("TODAY")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(AppColors.accent)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppColors.accent.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }
                    Text(day.kind.rawValue)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(hex: day.kind.accentHex))
                    Text("\(day.focus)")
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                    SoftProgressBar(
                        value: Double(day.loadPercent) / 100,
                        tint: Color(hex: day.kind.accentHex)
                    )
                    .padding(.top, 4)
                    Text(day.note)
                        .font(.caption2)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
        }
    }
}

// MARK: - Body part cell

struct BodyPartCell: View {
    let part: BodyPart
    let status: BodyPartLoadStatus?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            GlassCard(
                padding: 12,
                cornerRadius: 14,
                accent: Color(hex: status?.advice.colorHex ?? "#FDCC07")
            ) {
                VStack(spacing: 8) {
                    Text(part.icon)
                        .font(.title2)
                    Text(part.rawValue)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(status?.advice.rawValue ?? "OK to load")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color(hex: status?.advice.colorHex ?? "#4CAF50"))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                }
                .frame(maxWidth: .infinity)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? AppColors.accent : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PressableCardStyle())
    }
}

// MARK: - Settings / action cell

struct SettingsActionCell: View {
    let icon: String
    let title: String
    let subtitle: String
    var tint: Color = AppColors.recoveryPoor
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            GlassCard(padding: 14, cornerRadius: 16, accent: tint) {
                HStack(spacing: 12) {
                    IconBadge(systemName: icon, tint: tint, size: 42)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(AppColors.textPrimary)
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
        }
        .buttonStyle(PressableCardStyle())
    }
}

// MARK: - Chart bar cell

struct ChartBarCell: View {
    let label: String
    let value: Double
    var maxValue: Double = 100

    private var tint: Color {
        if value >= 70 { return AppColors.recoveryGood }
        if value >= 40 { return AppColors.recoveryMedium }
        return AppColors.recoveryPoor
    }

    var body: some View {
        VStack(spacing: 6) {
            Text("\(Int(value))%")
                .font(.caption2.weight(.bold))
                .foregroundStyle(AppColors.textSecondary)
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(AppGradients.progressFill(tint: tint))
                .frame(width: 28, height: max(CGFloat(value / max(maxValue, 1) * 90), 6))
                .overlay(alignment: .top) {
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 3)
                        .padding(.horizontal, 4)
                        .padding(.top, 2)
                        .allowsHitTesting(false)
                }
            Text(label)
                .font(.caption2)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Journal cell

struct DecisionJournalCell: View {
    let entry: DecisionJournalEntry

    var body: some View {
        GlassCard(padding: 14, cornerRadius: 16, accent: Color(hex: entry.kind.accentHex)) {
            HStack(spacing: 12) {
                Text(entry.kind.emoji)
                    .font(.title2)
                    .frame(width: 44, height: 44)
                    .background(Color(hex: entry.kind.accentHex).opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(entry.kind.rawValue)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppColors.textPrimary)
                    Text(AppDateFormatters.dayMonth.string(from: entry.date))
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                    if let note = entry.note {
                        Text(note)
                            .font(.caption2)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(entry.readinessScore))%")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(AppColors.accent)
                    if let followed = entry.followed {
                        Text(followed ? "Followed" : "Skipped")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(followed ? AppColors.recoveryGood : AppColors.recoveryPoor)
                    }
                }
            }
        }
    }
}

// MARK: - Ritual streak cell

struct RitualStreakCell: View {
    let title: String
    let value: Int
    let maxValue: Int
    var icon: String = "flame.fill"
    var tint: Color = AppColors.accent

    var body: some View {
        GlassCard(padding: 12, cornerRadius: 14, accent: tint, depth: .compact) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .foregroundStyle(tint)
                    Spacer()
                    Text("max \(maxValue)")
                        .font(.caption2)
                        .foregroundStyle(AppColors.textSecondary)
                }
                Text("\(value)")
                    .font(.title.bold())
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.textPrimary, tint.opacity(0.85)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                SoftProgressBar(
                    value: maxValue > 0 ? min(Double(value) / Double(max(maxValue, 1)), 1) : 0,
                    tint: tint,
                    height: 5
                )
            }
        }
    }
}

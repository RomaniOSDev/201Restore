import SwiftUI

struct DecisionView: View {
    @StateObject private var viewModel: DecisionViewModel

    init(viewModel: DecisionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(spacing: 16) {
                    ScreenTitleBar(
                        title: "Training Decision",
                        subtitle: "Coach call for today’s load",
                        onBack: viewModel.goBack
                    )

                    hero
                    readinessCard

                    planBCard

                    SectionHeader(title: "Why this call")
                        .padding(.horizontal, 20)
                    ForEach(viewModel.decision.reasons.prefix(6)) { reason in
                        DecisionReasonCell(reason: reason)
                            .padding(.horizontal, 20)
                    }

                    SectionHeader(title: "Zone status", actionTitle: "Body Map", action: viewModel.goToBodyMap)
                        .padding(.horizontal, 20)
                    zoneCard

                    followCard
                    comparisonCard
                    toolsRow
                }
                .padding(.bottom, 28)
            }
            .clearScrollBackground()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { viewModel.reload() }
    }

    private var hero: some View {
            GlassCard(padding: 18, cornerRadius: 22, accent: Color(hex: viewModel.decision.kind.accentHex), depth: .featured) {
            VStack(spacing: 14) {
                Text(viewModel.decision.kind.emoji)
                    .font(.system(size: 48))
                Text(viewModel.decision.kind.rawValue)
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color(hex: viewModel.decision.kind.accentHex))
                Text(viewModel.decision.summary)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)

                SoftProgressBar(
                    value: viewModel.decision.readinessScore / 100,
                    tint: Color(hex: viewModel.decision.kind.accentHex),
                    height: 10
                )

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    MetricCell(value: "\(Int(viewModel.decision.readinessScore))%", label: "Ready", tint: AppColors.accent, icon: "bolt.fill")
                    MetricCell(value: "\(viewModel.decision.recommendedLoadPercent)%", label: "Load", tint: Color(hex: viewModel.decision.kind.accentHex), icon: "gauge.with.needle")
                    MetricCell(value: shortSession, label: "Session", tint: AppColors.recoveryGood, icon: "figure.run")
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private var shortSession: String {
        let raw = viewModel.decision.sessionType.rawValue
        return raw.split(separator: " ").first.map(String.init) ?? raw
    }

    private var readinessCard: some View {
        GlassCard(padding: 16, cornerRadius: 18, accent: AppColors.accent) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Readiness Math")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                mathRow("Base recovery", "\(Int(viewModel.decision.baseRecoveryIndex))%", AppColors.textPrimary)
                mathRow("Injury penalty", "−\(Int(viewModel.decision.injuryPenalty))", AppColors.recoveryPoor)
                mathRow("Protocol bonus", "+\(Int(viewModel.decision.protocolBonus))", AppColors.recoveryGood)
                Divider().overlay(AppColors.textSecondary.opacity(0.2))
                mathRow("Final readiness", "\(Int(viewModel.decision.readinessScore))%", AppColors.accent)
            }
        }
        .padding(.horizontal, 20)
    }

    private var planBCard: some View {
        GlassCard(padding: 16, cornerRadius: 18, accent: AppColors.recoveryMedium) {
            VStack(alignment: .leading, spacing: 10) {
                Text("If you still train — Plan B")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                Text(viewModel.decision.planBTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.primary)
                Text(viewModel.decision.planBDetail)
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
                HStack {
                    Text("Load \(viewModel.decision.planBLoadPercent)%")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppColors.accent)
                    Spacer()
                    Text(viewModel.decision.planBSessionType.rawValue)
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
                Button("Start 10-min guided mobility") {
                    viewModel.goToGuidedRecovery()
                }
                .buttonStyle(PrimaryActionStyle(tint: AppColors.recoveryMedium))
            }
        }
        .padding(.horizontal, 20)
    }

    private var zoneCard: some View {
        VStack(spacing: 10) {
            if viewModel.decision.bodyLoad.isEmpty {
                GlassCard(padding: 14, cornerRadius: 16, accent: AppColors.recoveryGood) {
                    Text("No active injury limits today.")
                        .foregroundStyle(AppColors.textSecondary)
                }
            } else {
                ForEach(viewModel.decision.bodyLoad) { status in
                    AppListRowCell(
                        leadingEmoji: status.bodyPart.icon,
                        leadingIcon: nil,
                        title: status.bodyPart.rawValue,
                        subtitle: status.message,
                        badge: status.advice.rawValue,
                        badgeTint: Color(hex: status.advice.colorHex),
                        accent: Color(hex: status.advice.colorHex),
                        action: viewModel.goToBodyMap
                    )
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private var followCard: some View {
        GlassCard(padding: 16, cornerRadius: 18, accent: AppColors.accent) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Did you follow today’s call?")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                HStack(spacing: 10) {
                    followButton("Yes — followed", selected: viewModel.followedToday == true, tint: AppColors.recoveryGood) {
                        viewModel.markFollowed(true)
                    }
                    followButton("Skipped", selected: viewModel.followedToday == false, tint: AppColors.recoveryPoor) {
                        viewModel.markFollowed(false)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private var comparisonCard: some View {
        GlassCard(padding: 16, cornerRadius: 18, accent: AppColors.primary) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Followed vs skipped")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                HStack {
                    MetricCell(
                        value: "\(viewModel.followComparison.followedCount)",
                        label: "Followed",
                        tint: AppColors.recoveryGood,
                        icon: "checkmark"
                    )
                    MetricCell(
                        value: "\(viewModel.followComparison.skippedCount)",
                        label: "Skipped",
                        tint: AppColors.recoveryPoor,
                        icon: "xmark"
                    )
                }
                Text(viewModel.followComparison.message)
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(.horizontal, 20)
    }

    private var toolsRow: some View {
        HStack(spacing: 10) {
            FeatureNavCell(icon: "checklist", title: "Protocol", subtitle: "Recovery tasks", tint: AppColors.recoveryGood, action: viewModel.goToProtocol)
            FeatureNavCell(icon: "figure.run", title: "Session", subtitle: "Intent / RPE", tint: AppColors.accent, action: viewModel.goToSession)
        }
        .padding(.horizontal, 20)
    }

    private func mathRow(_ title: String, _ value: String, _ tint: Color) -> some View {
        HStack {
            Text(title).foregroundStyle(AppColors.textSecondary)
            Spacer()
            Text(value).fontWeight(.semibold).foregroundStyle(tint)
        }
        .font(.subheadline)
    }

    private func followButton(_ title: String, selected: Bool, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(selected ? tint.opacity(0.3) : AppColors.background.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(selected ? tint : AppColors.textSecondary.opacity(0.2), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(PressableCardStyle())
    }
}

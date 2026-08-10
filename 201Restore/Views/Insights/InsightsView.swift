import SwiftUI

struct InsightsView: View {
    @StateObject private var viewModel: InsightsViewModel

    init(viewModel: InsightsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(spacing: 16) {
                    ScreenTitleBar(
                        title: "Insights & Rituals",
                        subtitle: "Explainable trends, not just charts",
                        onBack: viewModel.goBack
                    )

                    GlassCard(padding: 16, cornerRadius: 18, accent: AppColors.primary) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Weekly report")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(AppColors.textPrimary)
                            Text("Share a text summary of readiness, follow/skip, clearances, and top insights.")
                                .font(.caption)
                                .foregroundStyle(AppColors.textSecondary)
                            Button("Share weekly report") {
                                viewModel.shareWeeklyReport()
                            }
                            .buttonStyle(PrimaryActionStyle())
                        }
                    }
                    .padding(.horizontal, 20)

                    GlassCard(padding: 16, cornerRadius: 18, accent: AppColors.accent) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Followed vs not")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(AppColors.textPrimary)
                            Text(viewModel.followComparison.message)
                                .font(.caption)
                                .foregroundStyle(AppColors.textSecondary)
                            HStack {
                                Text("Followed \(viewModel.followComparison.followedCount) · avg \(Int(viewModel.followComparison.avgReadinessWhenFollowed))%")
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(AppColors.recoveryGood)
                                Spacer()
                                Text("Skipped \(viewModel.followComparison.skippedCount) · avg \(Int(viewModel.followComparison.avgReadinessWhenSkipped))%")
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(AppColors.recoveryPoor)
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    SectionHeader(title: "Meaningful streaks")
                        .padding(.horizontal, 20)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        RitualStreakCell(title: "Rest kept", value: viewModel.rituals.restDayKept, maxValue: viewModel.rituals.maxRestDayKept, icon: "bed.double.fill", tint: AppColors.recoveryMedium)
                        RitualStreakCell(title: "Injury logged", value: viewModel.rituals.injuryLoggedSameDay, maxValue: viewModel.rituals.maxInjuryLoggedSameDay, icon: "cross.case.fill", tint: AppColors.recoveryPoor)
                        RitualStreakCell(title: "Protocol done", value: viewModel.rituals.protocolCompleted, maxValue: viewModel.rituals.maxProtocolCompleted, icon: "checklist", tint: AppColors.recoveryGood)
                        RitualStreakCell(title: "Decision followed", value: viewModel.rituals.decisionFollowed, maxValue: viewModel.rituals.maxDecisionFollowed, icon: "target", tint: AppColors.accent)
                    }
                    .padding(.horizontal, 20)

                    SectionHeader(title: "Personal patterns")
                        .padding(.horizontal, 20)

                    ForEach(viewModel.insights) { insight in
                        InsightCell(insight: insight)
                            .padding(.horizontal, 20)
                    }

                    if !viewModel.journal.isEmpty {
                        SectionHeader(title: "Decision journal")
                            .padding(.horizontal, 20)
                        ForEach(viewModel.journal) { entry in
                            DecisionJournalCell(entry: entry)
                                .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.bottom, 28)
            }
            .clearScrollBackground()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { viewModel.reload() }
        .sheet(isPresented: $viewModel.showShare) {
            ShareSheet(items: [viewModel.weeklyReport])
        }
    }
}

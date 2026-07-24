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

                    SectionHeader(title: "Meaningful streaks")
                        .padding(.horizontal, 20)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        RitualStreakCell(title: "Rest kept", value: viewModel.rituals.restDayKept, maxValue: viewModel.rituals.maxRestDayKept, icon: "bed.double.fill", tint: AppColors.recoveryMedium)
                        RitualStreakCell(title: "Injury logged", value: viewModel.rituals.injuryLoggedSameDay, maxValue: viewModel.rituals.maxInjuryLoggedSameDay, icon: "cross.case.fill", tint: AppColors.recoveryPoor)
                        RitualStreakCell(title: "Protocol done", value: viewModel.rituals.protocolCompleted, maxValue: viewModel.rituals.maxProtocolCompleted, icon: "checklist", tint: AppColors.recoveryGood)
                        RitualStreakCell(title: "Decision followed", value: viewModel.rituals.decisionFollowed, maxValue: viewModel.rituals.maxDecisionFollowed, icon: "target", tint: AppColors.accent)
                    }
                    .padding(.horizontal, 20)

                    SectionHeader(title: "Explainable trends")
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
    }
}

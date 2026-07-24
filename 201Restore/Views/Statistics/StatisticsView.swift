import SwiftUI

struct StatisticsView: View {
    @StateObject private var viewModel: StatisticsViewModel

    init(viewModel: StatisticsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(spacing: 16) {
                    ScreenTitleBar(
                        title: "Statistics",
                        subtitle: "Recovery performance overview",
                        onBack: viewModel.goBack,
                        trailing: AnyView(
                            Button {
                                viewModel.showShareSheet = true
                            } label: {
                                IconBadge(systemName: "square.and.arrow.up", tint: AppColors.accent, size: 36)
                            }
                        )
                    )

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        MetricCell(value: "\(viewModel.stats.totalEntries)", label: "Entries", tint: AppColors.accent, icon: "list.bullet")
                        MetricCell(value: "\(Int(viewModel.stats.averageRecoveryIndex))%", label: "Avg Index", tint: AppColors.recoveryGood, icon: "chart.line.uptrend.xyaxis")
                        MetricCell(value: "\(viewModel.stats.currentStreak)", label: "Streak", tint: AppColors.recoveryMedium, icon: "flame.fill")
                        MetricCell(value: "\(Int(viewModel.stats.bestRecoveryIndex))%", label: "Best", tint: AppColors.recoveryGood, icon: "star.fill")
                    }
                    .padding(.horizontal, 20)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        MetricCell(value: "\(Int(viewModel.stats.averageSleepQuality))", label: "Sleep", tint: AppColors.textSecondary, icon: "bed.double")
                        MetricCell(value: "\(Int(viewModel.stats.averageFatigue))", label: "Fatigue", tint: AppColors.recoveryPoor, icon: "battery.25")
                        MetricCell(value: "\(Int(viewModel.stats.averageSoreness))", label: "Soreness", tint: Color(hex: "FF9800"), icon: "figure.cooldown")
                    }
                    .padding(.horizontal, 20)

                    GlassCard(padding: 16, cornerRadius: 18, accent: AppColors.accent) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Weekly Progress")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(AppColors.textPrimary)
                            HStack(alignment: .bottom, spacing: 8) {
                                ForEach(viewModel.weeklyData, id: \.0) { day, value in
                                    ChartBarCell(label: day, value: value)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 140)
                        }
                    }
                    .padding(.horizontal, 20)

                    SectionHeader(title: "Level distribution")
                        .padding(.horizontal, 20)

                    ForEach(viewModel.recoveryLevelDistribution, id: \.0) { level, count in
                        AppListRowCell(
                            leadingEmoji: level.emoji,
                            leadingIcon: nil,
                            title: level.rawValue,
                            subtitle: "Entries at this readiness band",
                            trailing: nil,
                            badge: "\(count)",
                            badgeTint: AppColors.recovery(level),
                            accent: AppColors.recovery(level)
                        )
                        .padding(.horizontal, 20)
                    }

                    MetricCell(
                        value: "\(Int(viewModel.stats.worstRecoveryIndex))%",
                        label: "Worst Index",
                        tint: AppColors.recoveryPoor,
                        icon: "arrow.down.right"
                    )
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 28)
            }
            .clearScrollBackground()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { viewModel.loadData() }
        .sheet(isPresented: $viewModel.showShareSheet) {
            ShareSheet(items: [viewModel.shareText])
        }
    }
}

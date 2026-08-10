import SwiftUI

struct ProtocolView: View {
    @StateObject private var viewModel: ProtocolViewModel

    init(viewModel: ProtocolViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(spacing: 16) {
                    ScreenTitleBar(
                        title: "Recovery Protocol",
                        subtitle: "Checklist that boosts tomorrow",
                        onBack: viewModel.goBack
                    )

                    GlassCard(
                        padding: 18,
                        cornerRadius: 20,
                        accent: viewModel.tomorrowBoostUnlocked ? AppColors.recoveryGood : AppColors.accent
                    ) {
                        VStack(spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(viewModel.completionPercent)%")
                                        .font(.largeTitle.bold())
                                        .foregroundStyle(AppColors.textPrimary)
                                    Text("complete today")
                                        .font(.caption)
                                        .foregroundStyle(AppColors.textSecondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(viewModel.tomorrowBoostUnlocked ? "+5" : "+0")
                                        .font(.title.bold())
                                        .foregroundStyle(viewModel.tomorrowBoostUnlocked ? AppColors.recoveryGood : AppColors.textSecondary)
                                    Text("tomorrow readiness")
                                        .font(.caption2)
                                        .foregroundStyle(AppColors.textSecondary)
                                }
                            }
                            SoftProgressBar(value: viewModel.progress.completionRatio, tint: AppColors.accent, height: 10)
                            Text(viewModel.tomorrowBoostUnlocked
                                  ? "Boost unlocked — tomorrow’s readiness includes +5 from today’s protocol"
                                  : "Finish 75%+ to unlock +5 readiness tomorrow")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(viewModel.tomorrowBoostUnlocked ? AppColors.recoveryGood : AppColors.textSecondary)

                            Button("Open 10-min guided mobility") {
                                viewModel.goToGuidedRecovery()
                            }
                            .buttonStyle(PrimaryActionStyle())
                        }
                    }
                    .padding(.horizontal, 20)

                    if viewModel.timerRunning, let id = viewModel.activeTimerItemId,
                       let item = viewModel.items.first(where: { $0.id == id }) {
                        GlassCard(padding: 14, cornerRadius: 16, accent: AppColors.primary) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Timer · \(item.title)")
                                        .font(.subheadline.weight(.bold))
                                        .foregroundStyle(AppColors.textPrimary)
                                    Text(viewModel.timerLabel)
                                        .font(.title.bold().monospacedDigit())
                                        .foregroundStyle(AppColors.primary)
                                }
                                Spacer()
                                Button("Stop") { viewModel.stopTimer() }
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(AppColors.recoveryPoor)
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    SectionHeader(
                        title: "Today’s tasks",
                        subtitle: "Tuned for \(viewModel.decision.kind.rawValue.lowercased()) · scenario library"
                    )
                    .padding(.horizontal, 20)

                    ForEach(viewModel.items) { item in
                        ProtocolItemCell(
                            item: item,
                            isDone: viewModel.isDone(item.id),
                            onTimer: item.hasTimer ? { viewModel.startTimer(for: item) } : nil,
                            action: { viewModel.toggle(item.id) }
                        )
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 28)
            }
            .clearScrollBackground()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

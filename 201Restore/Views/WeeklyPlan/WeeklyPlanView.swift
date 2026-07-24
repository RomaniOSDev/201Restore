import SwiftUI

struct WeeklyPlanView: View {
    @StateObject private var viewModel: WeeklyPlanViewModel

    init(viewModel: WeeklyPlanViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(spacing: 16) {
                    ScreenTitleBar(
                        title: "Soft-Load Week",
                        subtitle: "Injury-aware 7-day sketch",
                        onBack: viewModel.goBack
                    )

                    GlassCard(padding: 14, cornerRadius: 16, accent: AppColors.accent) {
                        Text("Today is live from your readiness. Later days update automatically as you log condition.")
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .padding(.horizontal, 20)

                    ForEach(Array(viewModel.days.enumerated()), id: \.element.id) { index, day in
                        PlanDayCell(day: day, isToday: index == 0)
                            .padding(.horizontal, 20)
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

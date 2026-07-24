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

                    GlassCard(padding: 18, cornerRadius: 20, accent: AppColors.accent) {
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
                                IconBadge(systemName: "checkmark.seal.fill", tint: AppColors.recoveryGood, size: 48)
                            }
                            SoftProgressBar(value: viewModel.progress.completionRatio, tint: AppColors.accent, height: 10)
                            Text("Finish 75%+ to unlock +5 readiness tomorrow")
                                .font(.caption)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                    .padding(.horizontal, 20)

                    SectionHeader(
                        title: "Today’s tasks",
                        subtitle: "Tuned for \(viewModel.decision.kind.rawValue.lowercased())"
                    )
                    .padding(.horizontal, 20)

                    ForEach(viewModel.items) { item in
                        ProtocolItemCell(
                            item: item,
                            isDone: viewModel.isDone(item.id),
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

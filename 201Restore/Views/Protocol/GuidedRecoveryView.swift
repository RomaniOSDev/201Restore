import SwiftUI

struct GuidedRecoveryView: View {
    @StateObject private var viewModel: GuidedRecoveryViewModel

    init(viewModel: GuidedRecoveryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScreenContainer {
            VStack(spacing: 20) {
                ScreenTitleBar(
                    title: "Guided Mobility",
                    subtitle: "10-minute recovery session",
                    onBack: viewModel.goBack
                )

                Spacer(minLength: 8)

                GlassCard(padding: 24, cornerRadius: 22, accent: AppColors.primary, depth: .featured) {
                    VStack(spacing: 16) {
                        Text(viewModel.timeLabel)
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.primary)
                        SoftProgressBar(value: viewModel.progress, tint: AppColors.accent, height: 10)
                        Text(viewModel.cue)
                            .font(.headline)
                            .foregroundStyle(AppColors.textPrimary)
                            .multilineTextAlignment(.center)
                        Text(viewModel.isFinished ? "Session complete — mark protocol item done." : "Stay pain-free. Breathe slowly.")
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 20)

                HStack(spacing: 12) {
                    Button(viewModel.isRunning ? "Pause" : (viewModel.isFinished ? "Restart" : "Start")) {
                        viewModel.toggle()
                    }
                    .buttonStyle(PrimaryActionStyle())

                    Button("Reset") { viewModel.reset() }
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColors.card)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

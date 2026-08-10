import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel

    init(viewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(spacing: 16) {
                    ScreenTitleBar(
                        title: "Settings",
                        subtitle: "Data & preferences",
                        onBack: viewModel.goBack
                    )

                    SectionHeader(title: "Demo")
                        .padding(.horizontal, 20)

                    SettingsActionCell(
                        icon: "square.and.arrow.down.fill",
                        title: "Load Sample Data",
                        subtitle: "12 days of entries, injuries, decisions, protocols",
                        tint: AppColors.primary,
                        action: viewModel.loadSampleData
                    )
                    .padding(.horizontal, 20)

                    SectionHeader(title: "About")
                        .padding(.horizontal, 20)

                    SettingsActionCell(
                        icon: "star.fill",
                        title: "Rate Us",
                        subtitle: "Share feedback on the App Store",
                        tint: AppColors.recoveryMedium,
                        action: viewModel.rateApp
                    )
                    .padding(.horizontal, 20)

                    SettingsActionCell(
                        icon: "hand.raised.fill",
                        title: "Privacy Policy",
                        subtitle: "How your data is handled",
                        tint: AppColors.accent,
                        action: viewModel.openPrivacyPolicy
                    )
                    .padding(.horizontal, 20)

                    SettingsActionCell(
                        icon: "doc.text.fill",
                        title: "Terms of Use",
                        subtitle: "Rules for using the app",
                        tint: AppColors.accent,
                        action: viewModel.openTermsOfUse
                    )
                    .padding(.horizontal, 20)

                    SectionHeader(title: "App")
                        .padding(.horizontal, 20)

                    SettingsActionCell(
                        icon: "sparkles",
                        title: "Show Intro Again",
                        subtitle: "Replay the 3-screen coach walkthrough",
                        tint: AppColors.accent,
                        action: viewModel.replayOnboarding
                    )
                    .padding(.horizontal, 20)

                    SettingsActionCell(
                        icon: "trash.fill",
                        title: "Reset All Data",
                        subtitle: "Entries, injuries, protocols, sessions",
                        tint: AppColors.recoveryPoor,
                        action: { viewModel.showResetAlert = true }
                    )
                    .padding(.horizontal, 20)

                    GlassCard(padding: 16, cornerRadius: 16, accent: AppColors.textSecondary, depth: .compact) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("App build")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(AppColors.textPrimary)
                                Text("Local-only recovery coach")
                                    .font(.caption)
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                            Spacer()
                            Text("v1.1")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(AppColors.accent)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(AppColors.accent.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 28)
            }
            .clearScrollBackground()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .alert("Reset all data?", isPresented: $viewModel.showResetAlert) {
            Button("Reset", role: .destructive, action: viewModel.resetAllData)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("All entries, injuries, and statistics will be deleted.")
        }
    }
}

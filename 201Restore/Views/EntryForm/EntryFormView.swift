import SwiftUI

struct EntryFormView: View {
    @StateObject private var viewModel: EntryFormViewModel

    init(viewModel: EntryFormViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(spacing: 16) {
                    ScreenTitleBar(
                        title: viewModel.isEditing ? "Edit Condition" : "New Condition",
                        subtitle: "Sliders update readiness live",
                        onBack: viewModel.cancel
                    )

                    GlassCard(padding: 18, cornerRadius: 20, accent: AppColors.recovery(viewModel.recoveryLevel)) {
                        VStack(spacing: 12) {
                            Text("Recovery Index")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppColors.textSecondary)
                            RecoveryCircleView(
                                index: viewModel.recoveryIndex,
                                size: 110,
                                level: viewModel.recoveryLevel
                            )
                            RecoveryLevelBadge(level: viewModel.recoveryLevel)
                            SoftProgressBar(
                                value: viewModel.recoveryIndex / 100,
                                tint: AppColors.recovery(viewModel.recoveryLevel),
                                height: 8
                            )
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 20)

                    VStack(spacing: 12) {
                        ParameterSlider(title: "Fatigue", value: $viewModel.fatigue, color: AppColors.recoveryPoor)
                        ParameterSlider(title: "Muscle Soreness", value: $viewModel.muscleSoreness, color: AppColors.recoveryMedium)
                        ParameterSlider(title: "Sleep Quality", value: $viewModel.sleepQuality, color: AppColors.recoveryGood)
                        ParameterSlider(title: "Mood", value: $viewModel.mood, color: Color(hex: "FFD93D"))
                        ParameterSlider(title: "Energy", value: $viewModel.energy, color: AppColors.accent)
                    }
                    .padding(.horizontal, 20)

                    GlassCard(padding: 14, cornerRadius: 16, accent: AppColors.accent) {
                        DatePicker("Date", selection: $viewModel.date, displayedComponents: [.date])
                            .foregroundStyle(AppColors.textPrimary)
                            .tint(AppColors.accent)
                            .colorScheme(.dark)
                    }
                    .padding(.horizontal, 20)

                    GlassCard(padding: 14, cornerRadius: 16, accent: AppColors.textSecondary) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppColors.textSecondary)
                            TextEditor(text: $viewModel.notes)
                                .frame(minHeight: 90)
                                .foregroundStyle(AppColors.textPrimary)
                                .scrollContentBackground(.hidden)
                        }
                    }
                    .padding(.horizontal, 20)

                    Button(action: viewModel.saveEntry) {
                        Text(viewModel.isEditing ? "Save Changes" : "Add Condition")
                    }
                    .buttonStyle(PrimaryActionStyle())
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 28)
            }
            .clearScrollBackground()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct ParameterSlider: View {
    let title: String
    @Binding var value: Int
    let color: Color

    var body: some View {
        GlassCard(padding: 14, cornerRadius: 16, accent: color) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColors.textPrimary)
                    Spacer()
                    Text("\(value)/10")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(color.opacity(0.15))
                        .clipShape(Capsule())
                }

                SoftProgressBar(value: Double(value) / 10, tint: color, height: 6)

                Slider(
                    value: Binding(
                        get: { Double(value) },
                        set: { value = Int($0) }
                    ),
                    in: 1...10,
                    step: 1
                )
                .tint(color)
            }
        }
    }
}

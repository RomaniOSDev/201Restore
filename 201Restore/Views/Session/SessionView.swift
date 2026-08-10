import SwiftUI

struct SessionView: View {
    @StateObject private var viewModel: SessionViewModel

    init(viewModel: SessionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(spacing: 16) {
                    ScreenTitleBar(
                        title: "Session Check",
                        subtitle: "Intent before · review after",
                        onBack: viewModel.goBack
                    )

                    GlassCard(padding: 16, cornerRadius: 18, accent: AppColors.accent) {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Before", subtitle: "What do you plan today?")

                            Picker("Intent", selection: $viewModel.intent) {
                                ForEach(SessionIntent.allCases, id: \.self) { intent in
                                    Text(intent.rawValue).tag(intent)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(AppColors.accent)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppColors.background.opacity(0.55))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .onChange(of: viewModel.intent) { _, _ in
                                viewModel.intentChanged()
                            }

                            if let warning = viewModel.conflictWarning {
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(AppColors.recoveryPoor)
                                    Text(warning)
                                        .font(.caption)
                                        .foregroundStyle(AppColors.textPrimary)
                                }
                                .padding(12)
                                .background(AppColors.recoveryPoor.opacity(0.18))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }

                            TextField("Intent notes (optional)", text: $viewModel.intentNotes)
                                .padding(12)
                                .background(AppColors.background.opacity(0.55))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .foregroundStyle(AppColors.textPrimary)

                            Toggle("I followed today’s training decision", isOn: $viewModel.followedDecision)
                                .foregroundStyle(AppColors.textPrimary)
                                .tint(AppColors.accent)

                            Button("Save Intent") { viewModel.saveIntent() }
                                .buttonStyle(PrimaryActionStyle())
                        }
                    }
                    .padding(.horizontal, 20)

                    GlassCard(padding: 16, cornerRadius: 18, accent: AppColors.recoveryMedium) {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "After", subtitle: "How costly was the session?")

                            ParameterSlider(title: "RPE (effort)", value: $viewModel.rpe, color: AppColors.accent)

                            Text("Pain flared in")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppColors.textSecondary)

                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                                ForEach(BodyPart.allCases, id: \.self) { part in
                                    Button {
                                        viewModel.toggleWorsened(part)
                                    } label: {
                                        Text("\(part.icon) \(part.rawValue)")
                                            .font(.caption2.weight(.semibold))
                                            .foregroundStyle(AppColors.textPrimary)
                                            .padding(.vertical, 10)
                                            .frame(maxWidth: .infinity)
                                            .background(
                                                viewModel.worsened.contains(part)
                                                    ? AppColors.recoveryPoor.opacity(0.28)
                                                    : AppColors.background.opacity(0.55)
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    }
                                    .buttonStyle(PressableCardStyle())
                                }
                            }

                            TextEditor(text: $viewModel.painAfterNotes)
                                .frame(minHeight: 80)
                                .padding(12)
                                .background(AppColors.background.opacity(0.55))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .foregroundStyle(AppColors.textPrimary)
                                .scrollContentBackground(.hidden)

                            Button("Save Post-Check") { viewModel.savePostCheck() }
                                .buttonStyle(PrimaryActionStyle())
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
    }
}

struct PrimaryActionStyle: ButtonStyle {
    var tint: Color = AppColors.primary

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(Color.black.opacity(0.85))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppGradients.actionFill(accent: tint))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
            .depthShadow(.compact)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

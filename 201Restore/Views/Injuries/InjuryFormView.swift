import SwiftUI

struct InjuryFormView: View {
    @StateObject private var viewModel: InjuryFormViewModel

    init(viewModel: InjuryFormViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(spacing: 16) {
                    ScreenTitleBar(
                        title: viewModel.isEditing ? "Edit Injury" : "New Injury",
                        subtitle: "Updates pain history & load advice",
                        onBack: viewModel.cancel
                    )

                    GlassCard(padding: 14, cornerRadius: 16, accent: AppColors.accent) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Body Part")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppColors.textSecondary)
                            Picker("Body Part", selection: $viewModel.selectedBodyPart) {
                                ForEach(BodyPart.allCases, id: \.self) { part in
                                    Text("\(part.icon) \(part.rawValue)").tag(part)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(AppColors.accent)
                        }
                    }
                    .padding(.horizontal, 20)

                    ParameterSlider(
                        title: "Pain Level",
                        value: $viewModel.painLevel,
                        color: AppColors.recoveryPoor
                    )
                    .padding(.horizontal, 20)

                    GlassCard(padding: 14, cornerRadius: 16, accent: AppColors.accent) {
                        DatePicker("Date", selection: $viewModel.date, displayedComponents: [.date])
                            .foregroundStyle(AppColors.textPrimary)
                            .tint(AppColors.accent)
                            .colorScheme(.dark)
                    }
                    .padding(.horizontal, 20)

                    if viewModel.isEditing {
                        GlassCard(padding: 14, cornerRadius: 16, accent: AppColors.recoveryGood) {
                            Toggle("Still active", isOn: $viewModel.isActive)
                                .foregroundStyle(AppColors.textPrimary)
                                .tint(AppColors.accent)
                        }
                        .padding(.horizontal, 20)
                    }

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

                    Button(action: viewModel.saveInjury) {
                        Text(viewModel.isEditing ? "Save Changes" : "Add Injury")
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

import SwiftUI

struct InjuryListView: View {
    @StateObject private var viewModel: InjuryViewModel

    init(viewModel: InjuryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScreenContainer {
            VStack(spacing: 0) {
                ScreenTitleBar(
                    title: "Injuries",
                    subtitle: "Track pain, healing, load limits",
                    onBack: viewModel.goBack
                )

                ScrollView {
                    VStack(spacing: 14) {
                        HStack(spacing: 10) {
                            MetricCell(value: "\(viewModel.injuries.count)", label: "Total", tint: AppColors.textSecondary, icon: "list.bullet")
                            MetricCell(value: "\(viewModel.activeCount)", label: "Active", tint: AppColors.recoveryPoor, icon: "cross.case.fill")
                        }

                        GlassCard(padding: 12, cornerRadius: 16, accent: AppColors.accent) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundStyle(AppColors.textSecondary)
                                TextField("Search body part...", text: $viewModel.searchText)
                                    .foregroundStyle(AppColors.textPrimary)
                            }
                        }

                        Toggle("Show active only", isOn: $viewModel.showActiveOnly)
                            .foregroundStyle(AppColors.textPrimary)
                            .tint(AppColors.accent)
                            .padding(.horizontal, 4)

                        Button(action: { viewModel.goToInjuryForm() }) {
                            Label("Add Injury", systemImage: "plus.circle.fill")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(AppColors.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppColors.accent)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(PressableCardStyle())

                        FeatureNavCell(
                            icon: "figure.stand",
                            title: "Body Load Map",
                            subtitle: "See OK / Limit / Avoid by zone",
                            tint: AppColors.recoveryPoor,
                            action: viewModel.goToBodyMap
                        )

                        if viewModel.filteredInjuries.isEmpty {
                            EmptyStateView(
                                icon: "🩹",
                                title: "No Injuries",
                                message: viewModel.searchText.isEmpty
                                    ? "Add your first injury to start tracking"
                                    : "Nothing found",
                                buttonTitle: viewModel.searchText.isEmpty ? "Add" : "",
                                action: { viewModel.goToInjuryForm() }
                            )
                            .padding(.top, 24)
                        } else {
                            ForEach(viewModel.filteredInjuries) { injury in
                                InjuryRow(
                                    injury: injury,
                                    onTap: { viewModel.goToInjuryForm(injury: injury) },
                                    onHeal: { viewModel.healInjury(injury) },
                                    onDelete: { viewModel.deleteInjury(injury) }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 28)
                }
                .clearScrollBackground()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { viewModel.loadInjuries() }
    }
}

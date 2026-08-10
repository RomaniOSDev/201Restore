import SwiftUI

struct BodyMapView: View {
    @StateObject private var viewModel: BodyMapViewModel

    init(viewModel: BodyMapViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(spacing: 16) {
                    ScreenTitleBar(
                        title: "Body Load Map",
                        subtitle: "Can you load each zone today?",
                        onBack: viewModel.goBack
                    )

                    clearanceSection

                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(BodyPart.allCases, id: \.self) { part in
                            BodyPartCell(
                                part: part,
                                status: viewModel.statuses[part],
                                isSelected: viewModel.selected == part,
                                action: { viewModel.select(part) }
                            )
                        }
                    }
                    .padding(.horizontal, 20)

                    detailCard

                    if let injury = viewModel.selectedInjury {
                        painHistoryCard(injury)
                        returnToPlayCard
                    } else if !viewModel.returnToPlay.isEmpty {
                        returnToPlayCard
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

    private var clearanceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Activity clearances", subtitle: "Quick yes/no by zone stress")
                .padding(.horizontal, 20)

            ForEach(viewModel.clearances) { clearance in
                GlassCard(
                    padding: 14,
                    cornerRadius: 14,
                    accent: Color(hex: clearance.advice.colorHex)
                ) {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: clearance.allowed ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                            .foregroundStyle(Color(hex: clearance.advice.colorHex))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(clearance.activity)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(AppColors.textPrimary)
                            Text(clearance.reason)
                                .font(.caption)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        Spacer()
                        Text(clearance.allowed ? "YES" : "NO")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(clearance.allowed ? AppColors.recoveryGood : AppColors.recoveryPoor)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var detailCard: some View {
        let status = viewModel.selectedStatus
        return GlassCard(padding: 16, cornerRadius: 18, accent: Color(hex: status.advice.colorHex)) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Can I load \(status.bodyPart.rawValue)?")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)

                Text(status.advice.rawValue)
                    .font(.title3.bold())
                    .foregroundStyle(Color(hex: status.advice.colorHex))

                Text(status.message)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)

                if status.painLevel > 0 {
                    SoftProgressBar(value: Double(status.painLevel) / 10, tint: Color(hex: status.advice.colorHex))
                    Text("Pain \(status.painLevel)/10 · \(status.bodyPart.loadZone.rawValue)")
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Button(viewModel.selectedInjury == nil ? "Log Injury" : "Update Injury") {
                    viewModel.goToInjuryForm()
                }
                .buttonStyle(PrimaryActionStyle())
            }
        }
        .padding(.horizontal, 20)
    }

    private var returnToPlayCard: some View {
        GlassCard(padding: 16, cornerRadius: 18, accent: AppColors.accent) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Return-to-play · 7 days")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                Text("Progressive plan for \(viewModel.selectedInjury?.bodyPart.rawValue ?? "active injury")")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)

                ForEach(viewModel.returnToPlay) { day in
                    HStack(alignment: .top) {
                        Text(day.title)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppColors.primary)
                            .frame(width: 48, alignment: .leading)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(day.focus)
                                .font(.caption)
                                .foregroundStyle(AppColors.textPrimary)
                            Text("Load ~\(day.loadPercent)%")
                                .font(.caption2)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private func painHistoryCard(_ injury: Injury) -> some View {
        GlassCard(padding: 16, cornerRadius: 18, accent: AppColors.accent) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Pain over time")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)

                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(Array(injury.painHistory.suffix(10).enumerated()), id: \.offset) { _, sample in
                        ChartBarCell(label: "\(sample.level)", value: Double(sample.level) * 10, maxValue: 100)
                    }
                }

                if injury.painTrendDelta != 0 {
                    Text(injury.painTrendDelta < 0 ? "Trend improving (\(injury.painTrendDelta))" : "Trend rising (+\(injury.painTrendDelta))")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(injury.painTrendDelta < 0 ? AppColors.recoveryGood : AppColors.recoveryPoor)
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

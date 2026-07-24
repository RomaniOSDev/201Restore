import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel: CalendarViewModel

    init(viewModel: CalendarViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(spacing: 16) {
                    ScreenTitleBar(
                        title: "Recovery Calendar",
                        subtitle: "Tap a day to review or add",
                        onBack: viewModel.goBack
                    )

                    GlassCard(padding: 16, cornerRadius: 20, accent: AppColors.accent) {
                        VStack(spacing: 14) {
                            HStack {
                                Button { viewModel.shiftMonth(by: -1) } label: {
                                    IconBadge(systemName: "chevron.left", tint: AppColors.accent, size: 34)
                                }
                                Spacer()
                                Text(AppDateFormatters.monthYear.string(from: viewModel.displayedMonth))
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(AppColors.textPrimary)
                                Spacer()
                                Button { viewModel.shiftMonth(by: 1) } label: {
                                    IconBadge(systemName: "chevron.right", tint: AppColors.accent, size: 34)
                                }
                            }

                            HStack {
                                ForEach(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], id: \.self) { day in
                                    Text(day)
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(AppColors.textSecondary)
                                        .frame(maxWidth: .infinity)
                                }
                            }

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                                ForEach(Array(viewModel.daysInMonth.enumerated()), id: \.offset) { _, date in
                                    if let date {
                                        DayCell(
                                            date: date,
                                            emoji: viewModel.getEmoji(for: date),
                                            tint: viewModel.getColor(for: date),
                                            isSelected: Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate),
                                            onTap: { viewModel.selectedDate = date }
                                        )
                                    } else {
                                        Color.clear.frame(height: 54)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    selectedDayCard
                }
                .padding(.bottom, 28)
            }
            .clearScrollBackground()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { viewModel.loadEntries() }
    }

    @ViewBuilder
    private var selectedDayCard: some View {
        if let entry = viewModel.selectedEntry {
            GlassCard(padding: 16, cornerRadius: 18, accent: AppColors.recovery(entry.recoveryLevel)) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(AppDateFormatters.fullDate.string(from: entry.date))
                            .font(.headline.weight(.bold))
                            .foregroundStyle(AppColors.textPrimary)
                        Spacer()
                        Button("Edit", action: viewModel.goToEntryForm)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppColors.accent)
                    }

                    HStack(spacing: 14) {
                        RecoveryCircleView(index: entry.recoveryIndex, size: 64, level: entry.recoveryLevel)
                        VStack(alignment: .leading, spacing: 6) {
                            RecoveryLevelBadge(level: entry.recoveryLevel)
                            Text("\(Int(entry.recoveryIndex))% readiness")
                                .font(.caption)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        } else if Calendar.current.startOfDay(for: viewModel.selectedDate) <= Calendar.current.startOfDay(for: Date()) {
            GlassCard(padding: 16, cornerRadius: 18, accent: AppColors.accent) {
                VStack(spacing: 12) {
                    Text("No entry for this day")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textSecondary)
                    Button("Add Entry", action: viewModel.goToEntryForm)
                        .buttonStyle(PrimaryActionStyle())
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct DayCell: View {
    let date: Date
    let emoji: String
    let tint: Color
    let isSelected: Bool
    let onTap: () -> Void

    private var isFuture: Bool {
        Calendar.current.startOfDay(for: date) > Calendar.current.startOfDay(for: Date())
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.subheadline.weight(isSelected ? .bold : .medium))
                    .foregroundStyle(isSelected ? AppColors.textPrimary : AppColors.textSecondary)
                Text(emoji)
                    .font(.caption2)
                    .opacity(emoji == "○" ? 0.3 : 1)
            }
            .frame(height: 54)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        isSelected
                            ? AppColors.accent.opacity(0.28)
                            : (emoji == "○" ? AppColors.card.opacity(0.35) : tint.opacity(0.22))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected ? AppColors.accent : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(PressableCardStyle())
        .disabled(isFuture)
        .opacity(isFuture ? 0.28 : 1)
    }
}

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(spacing: 18) {
                    topBar

                    HomeHeroBanner(
                        readiness: Int(viewModel.todayDecision?.readinessScore ?? 0),
                        decisionTitle: viewModel.todayDecision?.kind.rawValue ?? "Log to unlock call",
                        onDecision: viewModel.goToDecision,
                        onAdd: viewModel.addEntry
                    )

                    if let decision = viewModel.todayDecision {
                        TrainingDecisionCard(decision: decision, onOpen: viewModel.goToDecision)
                    }

                    if let entry = viewModel.todayEntry {
                        TodayStatusCard(entry: entry, onEdit: viewModel.editEntry)
                    } else {
                        EmptyStateCard(onAdd: viewModel.addEntry)
                    }

                    SectionHeader(title: "Coach Toolkit", subtitle: "Visual shortcuts to today’s workflow")
                    imageToolkit

                    SectionHeader(title: "Live Snapshot")
                    statsRow

                    SectionHeader(title: "Quick Actions")
                    quickActions

                    if let insight = viewModel.topInsight {
                        SectionHeader(title: "Top Insight", actionTitle: "All", action: viewModel.goToInsights)
                        InsightCell(insight: insight, action: viewModel.goToInsights)
                    }

                    SectionHeader(title: "Meaningful Streaks")
                    ritualStrip

                    if !viewModel.recentEntries.isEmpty {
                        SectionHeader(title: "Recent Entries", actionTitle: "Calendar", action: viewModel.goToCalendar)
                        ForEach(viewModel.recentEntries) { entry in
                            RecentEntryRow(entry: entry) {
                                viewModel.editEntry()
                            }
                        }
                    }

                    if !viewModel.activeInjuries.isEmpty {
                        SectionHeader(title: "Active Injuries", actionTitle: "Map", action: viewModel.goToBodyMap)
                        ForEach(viewModel.activeInjuries.prefix(3)) { injury in
                            AppListRowCell(
                                leadingEmoji: injury.bodyPart.icon,
                                leadingIcon: nil,
                                title: injury.bodyPart.rawValue,
                                subtitle: "Pain \(injury.painLevel)/10 · \(injury.bodyPart.loadZone.rawValue)",
                                trailing: nil,
                                badge: injury.painLevel >= 7 ? "Avoid" : injury.painLevel >= 5 ? "Limit" : "Monitor",
                                badgeTint: injury.painLevel >= 7 ? AppColors.recoveryPoor : AppColors.recoveryMedium,
                                accent: AppColors.recoveryPoor,
                                action: viewModel.goToBodyMap
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .clearScrollBackground()
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { viewModel.loadData() }
    }

    private var topBar: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Good \(dayPart)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColors.primary)
                Text("Recovery Coach")
                    .font(.title.bold())
                    .foregroundStyle(AppColors.textPrimary)
            }
            Spacer()
            Button(action: viewModel.goToSettings) {
                IconBadge(systemName: "gearshape.fill", tint: AppColors.textSecondary, size: 42)
            }
            .buttonStyle(PressableCardStyle())
        }
    }

    private var dayPart: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "morning"
        case 12..<17: return "afternoon"
        case 17..<22: return "evening"
        default: return "night"
        }
    }

    private var imageToolkit: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ImageFeatureTile(
                imageName: "TileDecision",
                title: "Decision",
                subtitle: viewModel.todayDecision?.kind.rawValue ?? "Today’s training call",
                tint: Color(hex: viewModel.todayDecision?.kind.accentHex ?? "#FDCC07"),
                action: viewModel.goToDecision
            )
            ImageFeatureTile(
                imageName: "TileProtocol",
                title: "Protocol",
                subtitle: "\(viewModel.protocolPercent)% recovery tasks",
                tint: AppColors.recoveryGood,
                action: viewModel.goToProtocol
            )
            ImageFeatureTile(
                imageName: "TileSession",
                title: "Session",
                subtitle: viewModel.todaySession?.intent?.rawValue ?? "Intent + RPE check",
                tint: AppColors.accent,
                action: viewModel.goToSession
            )
            ImageFeatureTile(
                imageName: "TileBodyMap",
                title: "Body Map",
                subtitle: "\(viewModel.activeInjuries.count) active zones",
                tint: AppColors.recoveryPoor,
                action: viewModel.goToBodyMap
            )
            ImageFeatureTile(
                imageName: "TileInsights",
                title: "Insights",
                subtitle: "Explainable trends",
                tint: AppColors.recoveryMedium,
                action: viewModel.goToInsights
            )
            ImageFeatureTile(
                imageName: "TileWeekPlan",
                title: "Week Plan",
                subtitle: "Soft-load 7-day sketch",
                tint: AppColors.accent,
                action: viewModel.goToWeeklyPlan
            )
        }
    }

    private var statsRow: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            MetricCell(value: "\(viewModel.stats.totalEntries)", label: "Entries", tint: AppColors.accent, icon: "list.bullet")
            MetricCell(value: "\(viewModel.rituals.decisionFollowed)", label: "Followed", tint: AppColors.recoveryGood, icon: "checkmark.seal")
            MetricCell(value: "\(viewModel.stats.activeInjuries)", label: "Injuries", tint: AppColors.recoveryPoor, icon: "cross.case")
            MetricCell(value: "\(Int(viewModel.todayDecision?.readinessScore ?? 0))%", label: "Ready", tint: AppColors.recoveryMedium, icon: "bolt.fill")
        }
    }

    private var quickActions: some View {
        HStack(spacing: 10) {
            HomeQuickActionImageButton(systemIcon: "plus.circle.fill", title: "Add", tint: AppColors.accent, action: viewModel.addEntry)
            HomeQuickActionImageButton(systemIcon: "calendar", title: "Calendar", tint: AppColors.textSecondary, action: viewModel.goToCalendar)
            HomeQuickActionImageButton(systemIcon: "heart.circle.fill", title: "Injuries", tint: AppColors.recoveryPoor, action: viewModel.goToInjuries)
            HomeQuickActionImageButton(systemIcon: "chart.bar.fill", title: "Stats", tint: AppColors.recoveryGood, action: viewModel.goToStatistics)
        }
    }

    private var ritualStrip: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            RitualStreakCell(title: "Rest kept", value: viewModel.rituals.restDayKept, maxValue: viewModel.rituals.maxRestDayKept, icon: "bed.double.fill", tint: AppColors.recoveryMedium)
            RitualStreakCell(title: "Protocol", value: viewModel.rituals.protocolCompleted, maxValue: viewModel.rituals.maxProtocolCompleted, icon: "checklist", tint: AppColors.recoveryGood)
            RitualStreakCell(title: "Injury log", value: viewModel.rituals.injuryLoggedSameDay, maxValue: viewModel.rituals.maxInjuryLoggedSameDay, icon: "cross.case.fill", tint: AppColors.recoveryPoor)
            RitualStreakCell(title: "Followed", value: viewModel.rituals.decisionFollowed, maxValue: viewModel.rituals.maxDecisionFollowed, icon: "target", tint: AppColors.accent)
        }
    }
}

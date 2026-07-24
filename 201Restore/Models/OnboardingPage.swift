import Foundation

struct OnboardingPage: Identifiable, Hashable {
    let id: Int
    let imageName: String
    let title: String
    let subtitle: String
    let highlights: [String]

    static let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            imageName: "OnboardingDecision",
            title: "Train with a clear call",
            subtitle: "Each day you get Train Hard, Train Easy, Active Recovery, or Rest — based on readiness, not guesswork.",
            highlights: [
                "Readiness score with reasons",
                "Recommended load %",
                "Session type suggestion"
            ]
        ),
        OnboardingPage(
            id: 1,
            imageName: "OnboardingBodyMap",
            title: "Injuries shape the plan",
            subtitle: "Active pain zones limit load automatically. Check Body Map before you push a joint.",
            highlights: [
                "OK / Limit / Avoid advice",
                "Pain trend over time",
                "Zone-aware session picks"
            ]
        ),
        OnboardingPage(
            id: 2,
            imageName: "OnboardingProtocol",
            title: "Recover on purpose",
            subtitle: "Finish recovery checklists, log session intent + RPE, and unlock explainable insights.",
            highlights: [
                "Protocol boost for tomorrow",
                "Meaningful decision streaks",
                "Soft-load week sketch"
            ]
        )
    ]
}

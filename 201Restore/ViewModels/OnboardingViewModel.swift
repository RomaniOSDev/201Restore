import SwiftUI
import Combine

extension Notification.Name {
    static let replayOnboarding = Notification.Name("replayOnboarding")
}

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var currentPage: Int = 0

    let pages = OnboardingPage.pages

    var isLastPage: Bool {
        currentPage >= pages.count - 1
    }

    var progress: Double {
        guard pages.count > 1 else { return 1 }
        return Double(currentPage + 1) / Double(pages.count)
    }

    func next() {
        guard currentPage < pages.count - 1 else { return }
        withAnimation(.easeInOut(duration: 0.28)) {
            currentPage += 1
        }
    }

    func goTo(_ index: Int) {
        guard pages.indices.contains(index) else { return }
        withAnimation(.easeInOut(duration: 0.28)) {
            currentPage = index
        }
    }

    func complete(onFinished: () -> Void) {
        UserDefaults.standard.set(true, forKey: StorageKeys.onboardingCompleted)
        onFinished()
    }

    static var hasCompletedOnboarding: Bool {
        UserDefaults.standard.bool(forKey: StorageKeys.onboardingCompleted)
    }

    static func requestReplay() {
        UserDefaults.standard.set(false, forKey: StorageKeys.onboardingCompleted)
        NotificationCenter.default.post(name: .replayOnboarding, object: nil)
    }
}

import SwiftUI
import Combine
import StoreKit
import UIKit

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var showResetAlert = false

    private let recoveryEngine: RecoveryEngine
    private weak var coordinator: AppCoordinator?

    init(recoveryEngine: RecoveryEngine, coordinator: AppCoordinator) {
        self.recoveryEngine = recoveryEngine
        self.coordinator = coordinator
    }

    func resetAllData() {
        recoveryEngine.clearAllData()
        coordinator?.popToRoot()
    }

    func replayOnboarding() {
        OnboardingViewModel.requestReplay()
    }

    func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    func openPrivacyPolicy() {
        if let url = AppLinks.privacyPolicy.url {
            UIApplication.shared.open(url)
        }
    }

    func openTermsOfUse() {
        if let url = AppLinks.termsOfUse.url {
            UIApplication.shared.open(url)
        }
    }

    func goBack() {
        coordinator?.pop()
    }
}

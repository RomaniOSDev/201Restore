import SwiftUI

struct ContentView: View {
    @StateObject private var coordinator = AppCoordinator()
    @State private var showOnboarding = !OnboardingViewModel.hasCompletedOnboarding

    var body: some View {
        Group {
            if showOnboarding {
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        showOnboarding = false
                    }
                }
                .transition(.opacity)
            } else {
                NavigationStack(path: $coordinator.path) {
                    coordinator.start()
                        .navigationDestination(for: AppRoute.self) { route in
                            coordinator.destination(for: route)
                        }
                }
                .toolbarBackground(.hidden, for: .navigationBar)
                .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background.ignoresSafeArea(.all))
        .preferredColorScheme(.dark)
        .tint(AppColors.primary)
        .onReceive(NotificationCenter.default.publisher(for: .replayOnboarding)) { _ in
            coordinator.popToRoot()
            withAnimation(.easeInOut(duration: 0.35)) {
                showOnboarding = true
            }
        }
    }
}

#Preview {
    ContentView()
}

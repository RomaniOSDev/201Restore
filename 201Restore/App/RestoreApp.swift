import SwiftUI

/// UIKit entry point hosts `ContentView`. Helper for the SwiftUI composition root.
enum AppRootFactory {
    @MainActor
    static func makeRootView() -> some View {
        ContentView()
    }
}

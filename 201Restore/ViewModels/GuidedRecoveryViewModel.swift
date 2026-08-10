import SwiftUI
import Combine

@MainActor
final class GuidedRecoveryViewModel: ObservableObject {
    @Published var remainingSeconds: Int = 600
    @Published var isRunning = false
    @Published var isFinished = false

    private weak var coordinator: AppCoordinator?
    private var timer: Timer?
    private let totalSeconds = 600

    var progress: Double {
        1 - Double(remainingSeconds) / Double(totalSeconds)
    }

    var timeLabel: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%d:%02d", m, s)
    }

    var cue: String {
        let elapsed = totalSeconds - remainingSeconds
        switch elapsed {
        case 0..<120: return "Breathing + gentle neck resets"
        case 120..<300: return "Hip openers · pain-free range"
        case 300..<480: return "T-spine rotations · easy flow"
        default: return "Ankles + cool-down stretch"
        }
    }

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }

    func toggle() {
        if isRunning {
            pause()
        } else {
            start()
        }
    }

    func start() {
        guard !isFinished else { reset(); return }
        isRunning = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    func reset() {
        pause()
        remainingSeconds = totalSeconds
        isFinished = false
    }

    private func tick() {
        guard remainingSeconds > 0 else {
            isFinished = true
            pause()
            return
        }
        remainingSeconds -= 1
    }

    func goBack() {
        pause()
        coordinator?.pop()
    }

    deinit {
        timer?.invalidate()
    }
}

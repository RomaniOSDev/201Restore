import SwiftUI

struct RecoveryCircleView: View {
    let index: Double
    let size: CGFloat
    let level: RecoveryLevel

    private var color: Color {
        AppColors.recovery(level)
    }

    private var progress: CGFloat {
        CGFloat(min(max(index / 100, 0), 1))
    }

    var body: some View {
        ZStack {
            // Soft volume ring (opacity only — no blur).
            Circle()
                .stroke(color.opacity(0.18), lineWidth: 12)
                .frame(width: size, height: size)

            Circle()
                .stroke(AppColors.background.opacity(0.85), lineWidth: 8)
                .frame(width: size, height: size)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [color.opacity(0.55), color, color.opacity(0.85)],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.35), value: index)

            VStack(spacing: 2) {
                Text("\(Int(index))%")
                    .font(.system(size: size * 0.25, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)

                Text(level.emoji)
                    .font(.system(size: size * 0.2))
            }
        }
        .frame(width: size, height: size)
        .compositingGroup()
    }
}

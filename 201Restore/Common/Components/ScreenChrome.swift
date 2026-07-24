import SwiftUI

// MARK: - Design tokens (cheap, reusable, no blur)

enum DepthStyle: Equatable {
    case compact
    case standard
    case featured

    var cornerRadius: CGFloat {
        switch self {
        case .compact: return 14
        case .standard: return 18
        case .featured: return 22
        }
    }

    /// Small radii keep scrolling smooth on long lists.
    var shadowRadius: CGFloat {
        switch self {
        case .compact: return 4
        case .standard: return 7
        case .featured: return 10
        }
    }

    var shadowY: CGFloat {
        switch self {
        case .compact: return 2
        case .standard: return 4
        case .featured: return 6
        }
    }

    var shadowOpacity: Double {
        switch self {
        case .compact: return 0.18
        case .standard: return 0.24
        case .featured: return 0.30
        }
    }
}

enum AppGradients {
    /// #fdcc07 gold wash over plum background
    static let screenWash = LinearGradient(
        colors: [
            Color(red: 0.992, green: 0.800, blue: 0.027).opacity(0.18),
            Color.clear,
            Color(red: 0.333, green: 0.200, blue: 0.294).opacity(0.45)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let screenGlow = RadialGradient(
        colors: [
            Color(red: 0.992, green: 0.839, blue: 0.224).opacity(0.20),
            Color.clear
        ],
        center: .topTrailing,
        startRadius: 10,
        endRadius: 280
    )

    static func cardFill(accent: Color) -> LinearGradient {
        LinearGradient(
            colors: [
                AppColors.card,
                AppColors.card,
                accent.opacity(0.10)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func edgeSheen(accent: Color) -> LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.22),
                accent.opacity(0.45),
                accent.opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func actionFill(accent: Color) -> LinearGradient {
        LinearGradient(
            colors: [accent, accent.opacity(0.78)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func progressFill(tint: Color) -> LinearGradient {
        LinearGradient(
            colors: [tint.opacity(0.95), tint.opacity(0.65)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    static let heroScrim = LinearGradient(
        colors: [
            Color.clear,
            AppColors.background.opacity(0.25),
            AppColors.background.opacity(0.92)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Performance-minded modifiers

extension View {
    /// One shadow per surface — apply AFTER clip/background so children don’t nest shadows.
    func depthShadow(_ style: DepthStyle) -> some View {
        compositingGroup()
            .shadow(
                color: Color.black.opacity(style.shadowOpacity),
                radius: style.shadowRadius,
                x: 0,
                y: style.shadowY
            )
    }

    func clearScrollBackground() -> some View {
        scrollContentBackground(.hidden)
            .background(Color.clear)
    }

    func screenBackground() -> some View {
        background(AppColors.background.ignoresSafeArea())
    }
}

// MARK: - Background (edge-to-edge, no drawingGroup — it creates top/bottom gaps)

struct AppBackgroundView: View {
    var body: some View {
        ZStack {
            AppColors.background
            AppGradients.screenWash
            AppGradients.screenGlow
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all)
        .allowsHitTesting(false)
    }
}

struct ScreenContainer<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background.ignoresSafeArea(.all))
    }
}

// MARK: - Volume card (gradient fill + sheen + single shadow)

struct GlassCard<Content: View>: View {
    var padding: CGFloat = 16
    var cornerRadius: CGFloat? = nil
    var accent: Color? = nil
    var depth: DepthStyle = .standard
    @ViewBuilder var content: Content

    private var radius: CGFloat { cornerRadius ?? depth.cornerRadius }
    private var tint: Color { accent ?? AppColors.accent }

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(AppGradients.cardFill(accent: tint))
            }
            .overlay {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(AppGradients.edgeSheen(accent: tint), lineWidth: depth == .featured ? 1.2 : 1)
            }
            // Soft top highlight for volume without blur.
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(depth == .compact ? 0.04 : 0.07), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: depth == .featured ? 28 : 18)
                    .allowsHitTesting(false)
            }
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .depthShadow(depth)
    }
}

struct PressableCardStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .opacity(configuration.isPressed ? 0.94 : 1)
            // Short ease, no spring bounce (cheaper during fast taps/scroll).
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct GradientActionButtonStyle: ButtonStyle {
    var tint: Color = AppColors.primary

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(Color.black.opacity(0.85))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppGradients.actionFill(accent: tint))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
            .depthShadow(.compact)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct IconBadge: View {
    let systemName: String
    var tint: Color = AppColors.accent
    var size: CGFloat = 42

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [tint.opacity(0.28), tint.opacity(0.10)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .stroke(tint.opacity(0.28), lineWidth: 1)
            Image(systemName: systemName)
                .font(.system(size: size * 0.38, weight: .semibold))
                .foregroundStyle(tint)
        }
        .frame(width: size, height: size)
        // No shadow on badges — keeps list scrolling light.
    }
}

struct SoftProgressBar: View {
    let value: Double
    var tint: Color = AppColors.accent
    var height: CGFloat = 8

    var body: some View {
        GeometryReader { geo in
            let width = max(geo.size.width * min(max(value, 0), 1), height)
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppColors.background.opacity(0.75))
                Capsule()
                    .fill(AppGradients.progressFill(tint: tint))
                    .frame(width: width)
                    .overlay(alignment: .top) {
                        Capsule()
                            .fill(Color.white.opacity(0.18))
                            .frame(height: max(height * 0.35, 2))
                            .padding(.horizontal, 2)
                            .padding(.top, 1)
                            .allowsHitTesting(false)
                    }
            }
        }
        .frame(height: height)
    }
}

struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    Capsule()
                        .fill(AppGradients.actionFill(accent: AppColors.primary))
                        .frame(width: 4, height: 16)
                    Text(title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(AppColors.textPrimary)
                }
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .padding(.leading, 12)
                }
            }
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColors.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppColors.primary.opacity(0.12))
                    .clipShape(Capsule())
            }
        }
    }
}

struct ScreenTitleBar: View {
    let title: String
    var subtitle: String? = nil
    var onBack: (() -> Void)? = nil
    var trailing: AnyView? = nil

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            if let onBack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(AppColors.accent)
                        .frame(width: 38, height: 38)
                        .background(
                            Circle().fill(AppGradients.cardFill(accent: AppColors.accent))
                        )
                        .overlay(Circle().stroke(AppGradients.edgeSheen(accent: AppColors.accent), lineWidth: 1))
                        .depthShadow(.compact)
                }
                .buttonStyle(PressableCardStyle())
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.title2.bold())
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.textPrimary, AppColors.textPrimary.opacity(0.85)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }

            Spacer()

            if let trailing {
                trailing
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var buttonTitle: String = ""
    var action: (() -> Void)?

    var body: some View {
        GlassCard(padding: 24, cornerRadius: 20, accent: AppColors.accent) {
            VStack(spacing: 14) {
                Text(icon)
                    .font(.system(size: 46))

                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)

                if let action, !buttonTitle.isEmpty {
                    Button(action: action) {
                        Text(buttonTitle)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(AppColors.textPrimary)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 12)
                            .background(AppColors.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(PressableCardStyle())
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    let onFinished: () -> Void

    var body: some View {
        ScreenContainer {
            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                TabView(selection: $viewModel.currentPage) {
                    ForEach(viewModel.pages) { page in
                        OnboardingPageCard(page: page)
                            .tag(page.id)
                            .padding(.horizontal, 20)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.28), value: viewModel.currentPage)

                bottomControls
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 28)
            }
        }
    }

    private var topBar: some View {
        HStack {
            SoftProgressBar(value: viewModel.progress, tint: AppColors.accent, height: 6)
                .frame(maxWidth: 140)

            Spacer()

            if !viewModel.isLastPage {
                Button("Skip") {
                    viewModel.complete(onFinished: onFinished)
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.textSecondary)
            }
        }
    }

    private var bottomControls: some View {
        VStack(spacing: 14) {
            HStack(spacing: 8) {
                ForEach(viewModel.pages) { page in
                    Capsule()
                        .fill(
                            page.id == viewModel.currentPage
                                ? AppGradients.actionFill(accent: AppColors.accent)
                                : LinearGradient(
                                    colors: [AppColors.textSecondary.opacity(0.35), AppColors.textSecondary.opacity(0.2)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                        )
                        .frame(width: page.id == viewModel.currentPage ? 22 : 8, height: 8)
                        .animation(.easeOut(duration: 0.2), value: viewModel.currentPage)
                        .onTapGesture { viewModel.goTo(page.id) }
                }
            }

            if viewModel.isLastPage {
                Button("Get Started") {
                    viewModel.complete(onFinished: onFinished)
                }
                .buttonStyle(PrimaryActionStyle())
            } else {
                Button("Continue") {
                    viewModel.next()
                }
                .buttonStyle(PrimaryActionStyle())
            }
        }
    }
}

private struct OnboardingPageCard: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 8)

            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(AppGradients.cardFill(accent: AppColors.accent))
                    .depthShadow(.featured)

                Image(page.imageName)
                    .resizable()
                    .interpolation(.medium)
                    .scaledToFit()
                    .padding(18)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 280)
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(AppGradients.edgeSheen(accent: AppColors.accent), lineWidth: 1.2)
            )

            VStack(alignment: .leading, spacing: 10) {
                Text(page.title)
                    .font(.title2.bold())
                    .foregroundStyle(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(page.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 8) {
                    ForEach(page.highlights, id: \.self) { item in
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(AppColors.accent)
                            Text(item)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppColors.textPrimary)
                            Spacer(minLength: 0)
                        }
                        .padding(12)
                        .background(AppGradients.cardFill(accent: AppColors.accent))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(AppColors.accent.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
                .padding(.top, 4)
            }

            Spacer(minLength: 4)
        }
    }
}

#Preview {
    OnboardingView(onFinished: {})
        .preferredColorScheme(.dark)
}

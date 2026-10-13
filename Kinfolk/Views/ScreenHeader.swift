import SwiftUI

/// The top of every screen, centered: an optional small label, a big serif headline,
/// one gray line saying what's here, and an optional button or chips underneath.
struct ScreenHeader<Accessory: View>: View {
    var eyebrow: Text? = nil
    let title: String
    let subtitle: String
    @ViewBuilder var accessory: Accessory

    var body: some View {
        VStack(spacing: 12) {
            if let eyebrow {
                eyebrow
                    .font(Theme.ui(.caption, weight: .semibold))
                    .tracking(1.2)
                    .textCase(.uppercase)
                    .foregroundStyle(Theme.inkSoft)
            }
            Text(title)
                .font(Theme.display())
                .tracking(-0.6)
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Text(subtitle)
                .font(Theme.ui(.body))
                .tracking(-0.3)
                .foregroundStyle(Theme.inkSoft)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            accessory
                .padding(.top, 10)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 12)
        .padding(.top, 28)
        .padding(.bottom, 36)
    }
}

extension ScreenHeader where Accessory == EmptyView {
    init(eyebrow: Text? = nil, title: String, subtitle: String) {
        self.init(eyebrow: eyebrow, title: title, subtitle: subtitle) { EmptyView() }
    }
}

/// Heading at the top of a card, like "OCTOBER" or "GRANDKIDS".
struct SectionLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .font(Theme.ui(.caption, weight: .semibold))
            .tracking(1.2)
            .textCase(.uppercase)
            .foregroundStyle(Theme.inkSoft)
            .padding(.top, 18)
            .padding(.bottom, 6)
    }
}

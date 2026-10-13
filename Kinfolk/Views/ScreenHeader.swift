import SwiftUI

/// The same top on every tab: a big title, one plain line saying what the screen is for,
/// and an optional button or photo underneath.
struct ScreenHeader<Accessory: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder var accessory: Accessory

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(Theme.ui(.largeTitle, weight: .bold))
                .tracking(-0.4)
                .foregroundStyle(Theme.ink)
            Text(subtitle)
                .font(Theme.ui(.body))
                .foregroundStyle(Theme.ink.opacity(0.78))
                .fixedSize(horizontal: false, vertical: true)
            accessory
                .padding(.top, 14)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 12)
        .padding(.bottom, 28)
        .reportsHeaderBottom()
    }
}

extension ScreenHeader where Accessory == EmptyView {
    init(title: String, subtitle: String) {
        self.init(title: title, subtitle: subtitle) { EmptyView() }
    }
}

/// Heading at the top of a sheet, like "October" or "Grandkids".
/// Lives inside the sheet so it never sits on the color wave's edge.
struct SectionLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .font(Theme.ui(.footnote, weight: .semibold))
            .foregroundStyle(Theme.inkSoft)
            .padding(.top, 18)
            .padding(.bottom, 4)
    }
}

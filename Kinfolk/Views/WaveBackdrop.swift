import SwiftUI

/// A slow, warm color wave across the top of a screen.
/// It ends a little below the screen's header, so it never cuts through text or buttons,
/// and the first sheet of paper always covers its lower edge.
struct WaveBand: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if #available(iOS 18, *) {
                TimelineView(.animation(minimumInterval: 1 / 30, paused: reduceMotion)) { context in
                    mesh(at: reduceMotion ? 0 : context.date.timeIntervalSinceReferenceDate)
                }
            } else {
                LinearGradient(colors: [Theme.waveLight, Theme.waveHoney, Theme.wavePeach, Theme.waveClay],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            }
        }
        .accessibilityHidden(true)
    }

    @available(iOS 18, *)
    private func mesh(at t: TimeInterval) -> some View {
        let drift = { (speed: Double, amount: Double) in Float(amount * sin(t * speed)) }
        return MeshGradient(
            width: 3, height: 3,
            points: [
                [0, 0], [0.5, 0], [1, 0],
                [0, 0.45 + drift(0.31, 0.08)], [0.5 + drift(0.23, 0.18), 0.5 + drift(0.37, 0.12)], [1, 0.4 + drift(0.27, 0.10)],
                [0, 1], [0.5 + drift(0.19, 0.15), 1], [1, 1],
            ],
            colors: [
                Theme.waveLight, Theme.waveLight, Theme.waveHoney,
                Theme.waveHoney, Theme.wavePeach, Theme.waveClay,
                Theme.wavePeach, Theme.waveClay, Theme.waveDeep,
            ]
        )
    }
}

/// Where the bottom of the screen header is, measured from the top of the screen.
struct HeaderBottomKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

extension View {
    /// Puts the color wave behind the top of a screen. It reaches from the top edge
    /// to just under the ScreenHeader, and moves with it when the page scrolls.
    func waveBackdrop(overlap: CGFloat = 72) -> some View {
        backgroundPreferenceValue(HeaderBottomKey.self, alignment: .top) { headerBottom in
            WaveBand()
                .frame(height: max(0, headerBottom + overlap))
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(edges: .top)
        }
    }

    /// Reports this view's bottom edge so the color wave can end just below it.
    func reportsHeaderBottom() -> some View {
        background {
            GeometryReader { proxy in
                Color.clear.preference(key: HeaderBottomKey.self, value: proxy.frame(in: .global).maxY)
            }
        }
    }
}

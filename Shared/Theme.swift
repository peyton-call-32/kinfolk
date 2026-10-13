import SwiftUI
import UIKit

/// All colors and fonts live here. Change them in one place.
/// Depth comes from layers: a slow color wave at the back, sheets of paper
/// floating over it with soft layered shadows, and glass controls on top.
enum Theme {
    // MARK: Colors
    static let paper        = Color(hex: 0xF4EEE3) // background
    static let ink          = Color(hex: 0x2B2622) // main text
    static let inkSoft      = Color(hex: 0x7A6C5E) // dates, captions
    static let line         = Color(hex: 0xD9CFC0) // thin dividers
    static let accent       = Color(hex: 0x8A3B2E) // the heart and one main action per screen
    static let sheet        = Color(hex: 0xFBF8F2) // sheets of paper, photo borders, tab bar

    // The moving color wave at the top of each screen, light to deep
    static let waveLight    = Color(hex: 0xF7DCC2)
    static let waveHoney    = Color(hex: 0xEDC583)
    static let wavePeach    = Color(hex: 0xEE9F78)
    static let waveClay     = Color(hex: 0xCD6A45)
    static let waveDeep     = Color(hex: 0x9C4230)
    static let onAccent     = Color(hex: 0xF4EEE3)

    // MARK: Fonts
    // One typeface everywhere: Fraunces, a warm old-style serif with soft, rounded
    // edges, like an old cookbook. Its settings are tuned per use below.

    /// The story itself.
    static func story(_ size: CGFloat = 22, relativeTo style: Font.TextStyle = .title) -> Font {
        scaled(fraunces(size, weight: 400, soft: 50), like: style)
    }

    /// The question, in italic.
    static func question(_ size: CGFloat = 19, relativeTo style: Font.TextStyle = .title3) -> Font {
        scaled(fraunces(size, weight: 400, soft: 100, italic: true), like: style)
    }

    /// Buttons, tabs, titles and labels.
    static func ui(_ style: Font.TextStyle = .body, weight: Font.Weight = .regular) -> Font {
        let wght: CGFloat = if weight == .bold { 680 }
            else if weight == .semibold { 590 }
            else if weight == .medium { 520 }
            else { 430 }
        return scaled(fraunces(baseSize(style), weight: wght, soft: 100), like: style)
    }

    /// The Kinfolk wordmark: heavier, softest, with Fraunces' playful "wonky" letters.
    static func brand(_ size: CGFloat) -> Font {
        Font(fraunces(size, weight: 650, soft: 100, wonky: true))
    }

    private static func fraunces(_ size: CGFloat, weight: CGFloat, soft: CGFloat,
                                 italic: Bool = false, wonky: Bool = false) -> UIFont {
        let variation = UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String)
        let axes: [Int: CGFloat] = [
            0x6F70_737A: min(max(size, 9), 144), // 'opsz': letter shapes tuned to the size
            0x7767_6874: weight,                 // 'wght'
            0x534F_4654: soft,                   // 'SOFT': rounder, softer edges
            0x574F_4E4B: wonky ? 1 : 0,          // 'WONK': quirky leaning letters
        ]
        let descriptor = UIFontDescriptor(name: italic ? "Fraunces-9ptBlackItalic" : "Fraunces-9ptBlack", size: size)
            .addingAttributes([variation: axes])
        return UIFont(descriptor: descriptor, size: size)
    }

    /// Grows and shrinks with the phone's text size setting.
    private static func scaled(_ font: UIFont, like style: Font.TextStyle) -> Font {
        Font(UIFontMetrics(forTextStyle: uiTextStyle(style)).scaledFont(for: font))
    }

    private static func baseSize(_ style: Font.TextStyle) -> CGFloat {
        switch style {
        case .largeTitle: 34
        case .title: 28
        case .title2: 22
        case .title3: 20
        case .callout: 16
        case .subheadline: 15
        case .footnote: 13
        case .caption: 12
        case .caption2: 11
        default: 17
        }
    }

    private static func uiTextStyle(_ style: Font.TextStyle) -> UIFont.TextStyle {
        switch style {
        case .largeTitle: .largeTitle
        case .title: .title1
        case .title2: .title2
        case .title3: .title3
        case .headline: .headline
        case .callout: .callout
        case .subheadline: .subheadline
        case .footnote: .footnote
        case .caption: .caption1
        case .caption2: .caption2
        default: .body
        }
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

extension View {
    /// The one shadow in the app: a crisp edge, a close shadow, and a wide soft one,
    /// so sheets look like they float above the page.
    func paperLift(_ height: CGFloat = 1) -> some View {
        self
            .shadow(color: Theme.ink.opacity(0.06), radius: 1, y: 1)
            .shadow(color: Theme.ink.opacity(0.08), radius: 10 * height, y: 6 * height)
            .shadow(color: Theme.waveDeep.opacity(0.10), radius: 28 * height, y: 22 * height)
    }

    /// Puts content on a sheet of paper.
    func onSheet() -> some View {
        self
            .background(Theme.sheet, in: RoundedRectangle(cornerRadius: 6))
            .paperLift()
    }
}

/// A full-width thin rule in the divider color.
struct Rule: View {
    var body: some View {
        Rectangle().fill(Theme.line).frame(height: 1)
    }
}

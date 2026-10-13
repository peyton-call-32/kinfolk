import SwiftUI
import UIKit

/// All colors and fonts live here. Change them in one place.
/// The look follows scaling.com: lots of space, centered serif headlines,
/// small squared-off buttons, hairline borders and very soft shadows,
/// in Kinfolk's homey colors.
enum Theme {
    // MARK: Colors
    static let paper        = Color(hex: 0xF4EEE3) // background
    static let sheet        = Color(hex: 0xFBF8F2) // cards, bars, light buttons
    static let ink          = Color(hex: 0x2B2622) // main text, dark buttons
    static let inkSoft      = Color(hex: 0x7A6C5E) // dates, captions, gray lines of text
    static let line         = Color(hex: 0xD9CFC0) // hairline borders and dividers
    static let accent       = Color(hex: 0x8A3B2E) // terracotta: the heart and highlighted words
    static let honey        = Color(hex: 0xE5C383) // the one golden hero button
    static let honeyEdge    = Color(hex: 0xC9A262) // its border
    static let onAccent     = Color(hex: 0xF4EEE3)

    // MARK: Fonts
    // Libre Caslon Display for big headlines, Libre Caslon Text for the stories,
    // Instrument Sans for everything else.

    /// Big, thin serif headlines.
    static func display(_ size: CGFloat = 38, relativeTo style: Font.TextStyle = .largeTitle) -> Font {
        scaled(UIFont(name: "LibreCaslonDisplay-Regular", size: size)!, like: style)
    }

    /// The story itself.
    static func story(_ size: CGFloat = 21, relativeTo style: Font.TextStyle = .title3) -> Font {
        scaled(UIFont(name: "LibreCaslonText-Regular", size: size)!, like: style)
    }

    /// The question, in italic. Ligatures are off: this italic joins "st" with an old-fashioned swash.
    static func question(_ size: CGFloat = 18, relativeTo style: Font.TextStyle = .body) -> Font {
        let settings: [[UIFontDescriptor.FeatureKey: Int]] = [
            [.type: kLigaturesType, .selector: kCommonLigaturesOffSelector],
            [.type: kLigaturesType, .selector: kRareLigaturesOffSelector],
        ]
        let descriptor = UIFontDescriptor(name: "LibreCaslonText-Italic", size: size)
            .addingAttributes([.featureSettings: settings])
        return scaled(UIFont(descriptor: descriptor, size: size), like: style)
    }

    /// Buttons, tabs and labels.
    static func ui(_ style: Font.TextStyle = .body, weight: Font.Weight = .regular) -> Font {
        scaled(instrumentSans(baseSize(style), weight: weight), like: style)
    }

    /// The Kinfolk wordmark.
    static func brand(_ size: CGFloat) -> Font {
        Font(instrumentSans(size, weight: .bold))
    }

    private static func instrumentSans(_ size: CGFloat, weight: Font.Weight) -> UIFont {
        let wght: CGFloat = if weight == .bold { 700 }
            else if weight == .semibold { 600 }
            else if weight == .medium { 520 }
            else { 400 }
        let variation = UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String)
        let descriptor = UIFontDescriptor(name: "InstrumentSans-Regular", size: size)
            .addingAttributes([variation: [0x7767_6874: wght]]) // 'wght' axis
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
    /// The one shadow in the app: barely there, just enough to lift a surface.
    func softShadow(_ strength: Double = 1) -> some View {
        shadow(color: Theme.ink.opacity(0.06 * strength), radius: 18, y: 6)
    }

    /// A card: light paper with a hairline border and rounded corners.
    func onSheet() -> some View {
        self
            .background(Theme.sheet, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Theme.line, lineWidth: 1))
            .softShadow()
    }
}

/// A full-width thin rule in the divider color.
struct Rule: View {
    var body: some View {
        Rectangle().fill(Theme.line).frame(height: 1)
    }
}

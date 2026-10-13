import SwiftUI

enum ButtonKind {
    /// The main action on a screen: dark ink.
    case primary
    /// The one golden hero button, like "Hear Papa tell it".
    case highlight
    /// Everything else: light paper with a hairline border.
    case secondary
    /// The chosen tab or chip.
    case selected
}

/// Small, squared-off buttons with gently rounded corners, in the style of scaling.com.
struct KinfolkButtonStyle: ButtonStyle {
    var kind: ButtonKind
    var compact = false
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: compact ? 8 : 10)
        let pressed = configuration.isPressed
        configuration.label
            .font(Theme.ui(compact ? .footnote : .subheadline, weight: .semibold))
            .tracking(-0.2)
            .lineLimit(1)
            .foregroundStyle(foreground)
            .padding(.horizontal, compact ? 14 : 20)
            .frame(minHeight: compact ? 38 : 48)
            .background(fill, in: shape)
            .overlay(shape.strokeBorder(border, lineWidth: 1))
            .shadow(color: Theme.ink.opacity(kind == .secondary ? 0.04 : 0.10), radius: 8, y: 3)
            .contentShape(shape)
            .opacity(isEnabled ? (pressed ? 0.85 : 1) : 0.45)
            .scaleEffect(pressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: pressed)
            .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.5), trigger: pressed) { _, now in now }
    }

    private var fill: Color {
        switch kind {
        case .primary, .selected: Theme.ink
        case .highlight: Theme.honey
        case .secondary: Theme.sheet
        }
    }

    private var border: Color {
        switch kind {
        case .primary, .selected: Theme.ink
        case .highlight: Theme.honeyEdge
        case .secondary: Theme.line
        }
    }

    private var foreground: Color {
        switch kind {
        case .primary, .selected: Theme.sheet
        case .highlight, .secondary: Theme.ink
        }
    }
}

extension View {
    func kinfolkButton(_ kind: ButtonKind = .secondary, compact: Bool = false) -> some View {
        buttonStyle(KinfolkButtonStyle(kind: kind, compact: compact))
    }
}

/// A button label with a trailing arrow, like "Send to Papa →".
struct ArrowLabel: View {
    let title: String

    var body: some View {
        HStack(spacing: 10) {
            Text(title)
            Image(systemName: "arrow.right")
                .font(.system(size: 13, weight: .semibold))
        }
    }
}

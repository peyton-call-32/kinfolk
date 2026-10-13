import SwiftUI

enum ButtonKind {
    /// The one main action on a screen, in the accent color.
    case primary
    /// Everything else: clear cream glass.
    case secondary
    /// The chosen tab or chip, in dark ink.
    case selected
}

/// A soft glass pill: a translucent tinted body, a bright rim along the top,
/// gentle shading inside along the bottom, and a soft shadow underneath.
/// Used by every button, chip and the tab bar so they all match.
struct GlassPill: View {
    var kind: ButtonKind
    var pressed = false

    var body: some View {
        let shape = Capsule()
        ZStack {
            // Body
            if kind == .secondary {
                shape.fill(.ultraThinMaterial)
                shape.fill(Theme.sheet.opacity(0.55))
            } else {
                shape.fill(LinearGradient(colors: [top, base], startPoint: .top, endPoint: .bottom))
            }

            // Soft light inside the top edge
            shape
                .stroke(Color.white.opacity(kind == .secondary ? 0.9 : 0.35), lineWidth: 5)
                .blur(radius: 3)
                .offset(y: 2)
                .mask(shape)

            // Soft shade inside the bottom edge
            shape
                .stroke(Theme.ink.opacity(kind == .secondary ? 0.10 : 0.30), lineWidth: 6)
                .blur(radius: 4)
                .offset(y: -3)
                .mask(shape)

            // Crisp rim, brightest on top
            shape.strokeBorder(
                LinearGradient(colors: [Color.white.opacity(kind == .secondary ? 0.95 : 0.5),
                                        Color.white.opacity(0.08),
                                        Color.white.opacity(kind == .secondary ? 0.5 : 0.18)],
                               startPoint: .top, endPoint: .bottom),
                lineWidth: 1.2
            )
        }
        .shadow(color: glow.opacity(pressed ? 0.15 : 0.30), radius: pressed ? 5 : 12, y: pressed ? 3 : 8)
        .shadow(color: Theme.ink.opacity(0.10), radius: 1, y: 1)
    }

    private var base: Color {
        switch kind {
        case .primary: Theme.accent
        case .selected: Theme.ink
        case .secondary: Theme.sheet
        }
    }

    private var top: Color {
        switch kind {
        case .primary: Theme.waveClay
        case .selected: Color(hex: 0x51453C)
        case .secondary: Theme.sheet
        }
    }

    private var glow: Color {
        switch kind {
        case .primary: Theme.accent
        case .selected: Theme.ink
        case .secondary: Theme.waveDeep.opacity(0.6)
        }
    }
}

struct GlassPillButtonStyle: ButtonStyle {
    var kind: ButtonKind
    var compact = false
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        configuration.label
            .font(Theme.ui(compact ? .subheadline : .body, weight: .semibold))
            .lineLimit(1)
            .foregroundStyle(kind == .secondary ? Theme.ink : Theme.sheet)
            .padding(.horizontal, compact ? 11 : 22)
            .frame(minHeight: compact ? 42 : 52)
            .background(GlassPill(kind: kind, pressed: pressed))
            .contentShape(Capsule())
            .opacity(isEnabled ? 1 : 0.55)
            .scaleEffect(pressed ? 0.97 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: pressed)
            .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.5), trigger: pressed) { _, now in now }
    }
}

extension View {
    /// The app's buttons: soft glass pills.
    func kinfolkButton(_ kind: ButtonKind = .secondary, compact: Bool = false) -> some View {
        buttonStyle(GlassPillButtonStyle(kind: kind, compact: compact))
    }
}

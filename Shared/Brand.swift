import SwiftUI

/// The Kinfolk mark: a simple house.
struct KinfolkMark: View {
    var size: CGFloat = 28
    var color: Color = Theme.accent

    var body: some View {
        HouseShape()
            .fill(color)
            .overlay(HouseShape().stroke(color, style: StrokeStyle(lineWidth: size * 0.1, lineJoin: .round)))
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

/// The mark next to the name, set in Fraunces.
struct KinfolkWordmark: View {
    var size: CGFloat = 24

    var body: some View {
        HStack(spacing: size * 0.32) {
            KinfolkMark(size: size * 1.15)
            Text("Kinfolk")
                .font(Theme.brand(size))
                .tracking(-0.2)
                .foregroundStyle(Theme.ink)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Kinfolk")
    }
}

/// A simple house: pitched roof, square body.
struct HouseShape: Shape {
    func path(in rect: CGRect) -> Path {
        let inset = rect.width * 0.08
        let r = rect.insetBy(dx: inset, dy: inset)
        let eave = r.minY + r.height * 0.4
        return Path { p in
            p.move(to: CGPoint(x: r.midX, y: r.minY))
            p.addLine(to: CGPoint(x: r.maxX, y: eave))
            p.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
            p.addLine(to: CGPoint(x: r.minX, y: r.maxY))
            p.addLine(to: CGPoint(x: r.minX, y: eave))
            p.closeSubpath()
        }
    }
}

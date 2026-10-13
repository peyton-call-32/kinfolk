import SwiftUI

struct ChipOption: Identifiable {
    /// nil means "All".
    let value: String?
    let label: String
    var id: String { value ?? "all" }
}

/// A centered row of name chips, like "Papa  Grandma Bev  Grandpa Lou".
/// The chosen one is dark, the same as the selected tab.
struct ChipRow: View {
    let options: [ChipOption]
    @Binding var selection: String?

    var body: some View {
        ViewThatFits(in: .horizontal) {
            chips
            ScrollView(.horizontal) { chips }
                .scrollIndicators(.hidden)
                .scrollClipDisabled()
        }
    }

    private var chips: some View {
        HStack(spacing: 6) {
            ForEach(options) { option in
                let isSelected = selection == option.value
                Button(option.label) {
                    withAnimation(.snappy) { selection = option.value }
                }
                .kinfolkButton(isSelected ? .selected : .secondary, compact: true)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
    }
}

extension ChipOption {
    static var grandparents: [ChipOption] {
        Family.grandparents.map { ChipOption(value: $0.id, label: $0.name) }
    }
}

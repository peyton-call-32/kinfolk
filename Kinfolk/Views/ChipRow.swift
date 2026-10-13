import SwiftUI

struct ChipOption: Identifiable {
    /// nil means "All".
    let value: String?
    let label: String
    var id: String { value ?? "all" }
}

/// A row of name chips, like "Papa  Grandma Bev  Grandpa Lou".
/// The selected one is a dark pill, the same as the tab bar.
struct ChipRow: View {
    let options: [ChipOption]
    @Binding var selection: String?

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 6) {
                ForEach(options) { option in
                    let isSelected = selection == option.value
                    if isSelected {
                        Button(option.label) {}
                            .kinfolkButton(.selected, compact: true)
                            .accessibilityAddTraits(.isSelected)
                    } else {
                        Button(option.label) {
                            withAnimation(.snappy) { selection = option.value }
                        }
                        .kinfolkButton(compact: true)
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
    }
}

extension ChipOption {
    static var grandparents: [ChipOption] {
        Family.grandparents.map { ChipOption(value: $0.id, label: $0.name) }
    }
}

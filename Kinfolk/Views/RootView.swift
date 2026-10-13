import SwiftUI

enum AppTab: String, CaseIterable {
    case today = "Today", stories = "Stories", ask = "Ask", family = "Family"
}

struct RootView: View {
    @State private var selection: AppTab = .today
    @Namespace private var tabPill

    var body: some View {
        Group {
            switch selection {
            case .today: TodayView()
            case .stories: StoriesView()
            case .ask: AskView()
            case .family: FamilyView()
            }
        }
        .id(selection)
        .transition(.asymmetric(insertion: .opacity.combined(with: .offset(y: 14)),
                                removal: .opacity))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.paper.ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) { tabBar }
        .onOpenURL { _ in selection = .today } // opened from the widget
    }

    /// Floating glass pill of text tabs. The selected tab sits in a dark glass pill that slides over.
    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                let isSelected = selection == tab
                Button {
                    withAnimation(.snappy(duration: 0.35)) { selection = tab }
                } label: {
                    Text(tab.rawValue)
                        .font(Theme.ui(.body, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? Theme.sheet : Theme.inkSoft)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background {
                            if isSelected {
                                GlassPill(kind: .selected)
                                    .matchedGeometryEffect(id: "pill", in: tabPill)
                            }
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(6)
        .background(GlassPill(kind: .secondary))
        .padding(.horizontal, 20)
        .padding(.bottom, 6)
    }
}


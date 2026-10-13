import SwiftUI

enum AppTab: String, CaseIterable {
    case today = "Today", stories = "Stories", ask = "Ask", family = "Family"
}

struct RootView: View {
    @State private var selection: AppTab = .today
    @Namespace private var tabHighlight

    var body: some View {
        VStack(spacing: 0) {
            topBar
            Group {
                switch selection {
                case .today: TodayView()
                case .stories: StoriesView()
                case .ask: AskView()
                case .family: FamilyView()
                }
            }
            .id(selection)
            .transition(.asymmetric(insertion: .opacity.combined(with: .offset(y: 10)),
                                    removal: .opacity))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Theme.paper.ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) { tabBar }
        .onOpenURL { _ in selection = .today } // opened from the widget
    }

    /// Floating bar across the top: the Kinfolk name, and a shortcut to ask a question.
    private var topBar: some View {
        HStack {
            KinfolkWordmark(size: 20)
            Spacer()
            if selection != .ask {
                Button { switchTo(.ask) } label: { Text("Ask a question") }
                    .kinfolkButton(.secondary, compact: true)
            }
        }
        .padding(.leading, 16)
        .padding(.trailing, 8)
        .frame(height: 54)
        .background(Theme.sheet, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Theme.line, lineWidth: 1))
        .softShadow()
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 4)
        .zIndex(1)
    }

    /// Floating bar of text tabs. The chosen tab sits on a dark tile that slides over.
    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                let isSelected = selection == tab
                Button { switchTo(tab) } label: {
                    Text(tab.rawValue)
                        .font(Theme.ui(.subheadline, weight: isSelected ? .semibold : .medium))
                        .tracking(-0.2)
                        .foregroundStyle(isSelected ? Theme.sheet : Theme.inkSoft)
                        .frame(maxWidth: .infinity, minHeight: 46)
                        .background {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Theme.ink)
                                    .matchedGeometryEffect(id: "tab", in: tabHighlight)
                            }
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(5)
        .background(Theme.sheet, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Theme.line, lineWidth: 1))
        .softShadow(1.5)
        .padding(.horizontal, 16)
        .padding(.bottom, 6)
    }

    private func switchTo(_ tab: AppTab) {
        withAnimation(.snappy(duration: 0.3)) { selection = tab }
    }
}

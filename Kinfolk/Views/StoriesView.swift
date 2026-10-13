import SwiftUI

struct StoriesView: View {
    @Environment(FamilyStore.self) private var store
    @State private var filter: String?

    private var stories: [Story] {
        store.stories.filter { filter == nil || $0.grandparentID == filter }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ScreenHeader(title: "Stories",
                                 subtitle: "Newest first.") {
                        ChipRow(options: [ChipOption(value: nil, label: "All")] + ChipOption.grandparents,
                                selection: $filter)
                    }

                    if stories.isEmpty {
                        Text(emptyText)
                            .font(Theme.ui(.body))
                            .foregroundStyle(Theme.inkSoft)
                            .padding(18)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .onSheet()
                    }

                    ForEach(months, id: \.self) { month in
                        let monthStories = stories.filter { monthName($0) == month }
                        VStack(alignment: .leading, spacing: 0) {
                            SectionLabel(text: month)
                            ForEach(monthStories) { story in
                                if story.id != monthStories.first?.id { Rule() }
                                NavigationLink {
                                    ScrollView {
                                        StoryScreen(story: story, date: story.answeredDate)
                                            .padding(.horizontal, 16)
                                            .padding(.bottom, 32)
                                    }
                                    .background(Theme.paper.ignoresSafeArea())
                                } label: {
                                    row(story)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 18)
                        .onSheet()
                        .padding(.bottom, 20)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
                .animation(.snappy, value: filter)
            }
            .background(Theme.paper.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
        .tint(Theme.ink)
    }

    private var emptyText: String {
        if let filter {
            let grandparent = Family.grandparent(filter)
            return "\(grandparent.name)'s stories will show up here after the first answer."
        }
        return "Stories will show up here after your grandparents answer their first questions."
    }

    /// Month names in the order stories appear (newest first).
    private var months: [String] {
        var seen: [String] = []
        for story in stories where !seen.contains(monthName(story)) {
            seen.append(monthName(story))
        }
        return seen
    }

    private func monthName(_ story: Story) -> String {
        story.answeredDate.formatted(.dateTime.month(.wide))
    }

    /// Two lines: what the story is about, then who told it and when.
    private func row(_ story: Story) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(story.title)
                    .font(Theme.story(19, relativeTo: .body))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(2)
                Text("\(story.grandparent.name) · \(story.answeredDate.formatted(.dateTime.month(.abbreviated).day()))")
                    .font(Theme.ui(.footnote))
                    .foregroundStyle(Theme.inkSoft)
            }
            Spacer(minLength: 0)
            if story.isRecording {
                Image(systemName: "waveform")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Theme.accent)
                    .accessibilityLabel("Recording")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

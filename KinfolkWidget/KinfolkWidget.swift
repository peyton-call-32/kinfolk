import SwiftUI
import WidgetKit

struct DailyStoryEntry: TimelineEntry {
    let date: Date
    let story: Story
}

struct DailyStoryProvider: TimelineProvider {
    func placeholder(in context: Context) -> DailyStoryEntry {
        DailyStoryEntry(date: .now, story: SampleStories.story())
    }

    func getSnapshot(in context: Context, completion: @escaping (DailyStoryEntry) -> Void) {
        completion(DailyStoryEntry(date: .now, story: SampleStories.story()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyStoryEntry>) -> Void) {
        let now = Date.now
        let entry = DailyStoryEntry(date: now, story: SampleStories.story(for: now))
        // Refresh just after midnight so the widget changes with the app.
        let calendar = Calendar.current
        let nextMidnight = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))!
        completion(Timeline(entries: [entry], policy: .after(nextMidnight)))
    }
}

struct KinfolkWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: DailyStoryEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(entry.story.text)
                .font(Theme.story(family == .systemSmall ? 14 : 17, relativeTo: .body))
                .foregroundStyle(Theme.ink)
                .lineSpacing(3)

            Spacer(minLength: 8)

            HStack(spacing: 6) {
                KinfolkMark(size: 13)
                Text("\(entry.story.grandparent.name) · \(entry.date.formatted(.dateTime.month(.abbreviated).day()))")
                    .font(Theme.ui(.caption))
                    .foregroundStyle(Theme.inkSoft)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(Theme.paper, for: .widget)
        .widgetURL(URL(string: "kinfolk://today"))
    }
}

struct KinfolkWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "KinfolkDailyStory", provider: DailyStoryProvider()) { entry in
            KinfolkWidgetView(entry: entry)
        }
        .configurationDisplayName("Kinfolk")
        .description("A new story from one of your grandparents every day.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

@main
struct KinfolkWidgetBundle: WidgetBundle {
    var body: some Widget {
        KinfolkWidget()
    }
}

#Preview(as: .systemMedium) {
    KinfolkWidget()
} timeline: {
    DailyStoryEntry(date: .now, story: SampleStories.story())
}

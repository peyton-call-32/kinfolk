import PhotosUI
import SwiftUI

struct TodayView: View {
    var body: some View {
        ScrollView {
            StoryScreen(story: SampleStories.story(), date: .now, dateStyle: .dateTime.weekday(.wide).month(.wide).day())
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
        }
    }
}

/// A full story: a centered headline about it, then the story on a card.
/// Used for Today and when opening a story from the Stories list.
struct StoryScreen: View {
    let story: Story
    let date: Date
    var dateStyle: Date.FormatStyle = .dateTime.month(.wide).day()

    var body: some View {
        VStack(spacing: 0) {
            StoryFrom(story: story, isToday: Calendar.current.isDateInToday(date))
                .padding(.top, 24)

            ScreenHeader(
                eyebrow: Text(date.formatted(dateStyle)),
                title: story.title
            ) {
                VStack(spacing: 20) {
                    QuestionQuote(question: story.question)

                    if case .voice(let seconds) = story.answerType {
                        Button {} label: {
                            HStack(spacing: 10) {
                                Image(systemName: "play.fill")
                                Text("Hear \(story.grandparent.name) tell it")
                                Text(Duration.seconds(seconds).formatted(.time(pattern: .minuteSecond)))
                                    .opacity(0.65)
                                    .monospacedDigit()
                            }
                        }
                        .kinfolkButton(.highlight)
                    }
                }
            }

            StoryPage(story: story)
        }
    }
}

/// The question the story answers, in quotes, under a small label.
struct QuestionQuote: View {
    let question: String

    var body: some View {
        VStack(spacing: 8) {
            Text("The question")
                .font(Theme.ui(.caption, weight: .semibold))
                .tracking(1.2)
                .textCase(.uppercase)
                .foregroundStyle(Theme.inkSoft)
            Text("\u{201C}\(question)\u{201D}")
                .font(Theme.question(21, relativeTo: .title3))
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .overlay(alignment: .top) { Rule().frame(width: 40) }
        .accessibilityElement(children: .combine)
    }
}

/// The story on a card: the story, a caption, and reactions.
struct StoryPage: View {
    let story: Story
    @State private var loved = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(story.text)
                .font(Theme.story())
                .foregroundStyle(Theme.ink)
                .lineSpacing(7)

            Text(story.caption)
                .font(Theme.ui(.footnote))
                .foregroundStyle(Theme.inkSoft)
                .padding(.top, 16)

            HStack(spacing: 12) {
                Button { loved.toggle() } label: {
                    HStack(spacing: 8) {
                        Image(systemName: loved ? "heart.fill" : "heart")
                            .foregroundStyle(Theme.accent)
                            .symbolEffect(.bounce, value: loved)
                        Text("Love it")
                    }
                }
                Button("Reply") {}
            }
            .kinfolkButton()
            .padding(.top, 20)
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onSheet()
    }
}

/// Who the story is from, big and centered at the top: their photo
/// (or their initial, tap to add a photo) and their name.
struct StoryFrom: View {
    let story: Story
    var isToday = false
    @Environment(FamilyStore.self) private var store
    @State private var photoItem: PhotosPickerItem?

    private var name: String { story.grandparent.name }
    private var photo: UIImage? { store.photos[story.grandparentID] }

    var body: some View {
        VStack(spacing: 14) {
            PhotosPicker(selection: $photoItem, matching: .images) {
                portrait
            }
            .buttonStyle(.plain)
            .accessibilityLabel(photo == nil ? "Add a photo of \(name)" : "Photo of \(name). Tap to change it.")

            VStack(spacing: 4) {
                Text(isToday ? "Today's story is from" : "A story from")
                    .font(Theme.ui(.footnote))
                    .foregroundStyle(Theme.inkSoft)
                Text(name)
                    .font(Theme.display(30, relativeTo: .title))
                    .tracking(-0.4)
                    .foregroundStyle(Theme.accent)
            }
            .accessibilityElement(children: .combine)
        }
        .frame(maxWidth: .infinity)
        .onChange(of: photoItem) {
            Task {
                if let data = try? await photoItem?.loadTransferable(type: Data.self) {
                    store.setPhoto(data, for: story.grandparentID)
                }
            }
        }
    }

    /// A small snapshot, slightly tilted. Without a photo, their initial and a camera badge.
    private var portrait: some View {
        Group {
            if let photo {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
            } else {
                Text(name.split(separator: " ").last.map { String($0.prefix(1)) } ?? "")
                    .font(Theme.display(40, relativeTo: .largeTitle))
                    .foregroundStyle(Theme.accent)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Theme.paper)
            }
        }
        .frame(width: 84, height: 84)
        .clipped()
        .padding(5)
        .background(Theme.sheet)
        .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 1))
        .softShadow(1.5)
        .overlay(alignment: .bottomTrailing) {
            if photo == nil {
                Image(systemName: "camera.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.onAccent)
                    .frame(width: 28, height: 28)
                    .background(Theme.accent, in: Circle())
                    .offset(x: 8, y: 8)
            }
        }
        .rotationEffect(.degrees(-3))
    }
}

#Preview {
    RootView().environment(FamilyStore())
}

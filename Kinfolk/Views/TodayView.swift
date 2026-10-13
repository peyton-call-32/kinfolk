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
            ScreenHeader(
                eyebrow: Text("\(date.formatted(dateStyle)) · From ") + Text(story.grandparent.name).foregroundColor(Theme.accent),
                title: story.title,
                subtitle: story.questionLine
            ) {
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

            StoryPage(story: story)
        }
    }
}

/// The story on a card: who it's from, the story, a caption, and reactions.
struct StoryPage: View {
    let story: Story
    @Environment(FamilyStore.self) private var store
    @State private var loved = false
    @State private var photoItem: PhotosPickerItem?

    private var name: String { story.grandparent.name }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            Text(story.text)
                .font(Theme.story())
                .foregroundStyle(Theme.ink)
                .lineSpacing(7)
                .padding(.top, 20)

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
        .onChange(of: photoItem) {
            Task {
                if let data = try? await photoItem?.loadTransferable(type: Data.self) {
                    store.setPhoto(data, for: story.grandparentID)
                }
            }
        }
    }

    /// Who the story is from: their photo (or a button to add one) and name.
    private var header: some View {
        HStack(spacing: 14) {
            if let image = store.photos[story.grandparentID] {
                PhotosPicker(selection: $photoItem, matching: .images) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .clipped()
                        .padding(4)
                        .background(Theme.sheet)
                        .softShadow()
                        .rotationEffect(.degrees(-3))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Photo of \(name). Tap to change it.")
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(Theme.ui(.headline, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                Text(story.formLabel)
                    .font(Theme.ui(.footnote))
                    .foregroundStyle(Theme.inkSoft)
            }

            Spacer(minLength: 0)

            if store.photos[story.grandparentID] == nil {
                PhotosPicker(selection: $photoItem, matching: .images) {
                    Text("Add a photo")
                }
                .kinfolkButton(compact: true)
                .accessibilityLabel("Add a photo of \(name)")
            }
        }
    }
}

#Preview {
    RootView().environment(FamilyStore())
}

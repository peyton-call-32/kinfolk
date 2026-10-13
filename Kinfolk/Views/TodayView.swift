import PhotosUI
import SwiftUI

struct TodayView: View {
    private let story = SampleStories.story()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                KinfolkWordmark(size: 24)
                    .padding(.top, 4)
                    .padding(.bottom, 20)
                    .padding(.horizontal, 8)

                ScreenHeader(title: "Today",
                             subtitle: "\(Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day())) · From \(story.grandparent.name)")
                    .padding(.horizontal, 8)

                StoryPage(story: story)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .waveBackdrop()
    }
}

/// One story laid out like a letter on a sheet of paper:
/// who it's from, the question, recording, story, caption, reactions.
/// Used on Today and when opening a story from the Stories list.
struct StoryPage: View {
    let story: Story
    @Environment(FamilyStore.self) private var store
    @State private var loved = false
    @State private var photoItem: PhotosPickerItem?

    private var name: String { story.grandparent.name }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            Text(story.questionLine)
                .font(Theme.question())
                .foregroundStyle(Theme.inkSoft)
                .padding(.top, 20)

            if case .voice(let seconds) = story.answerType {
                Button {} label: {
                    HStack(spacing: 10) {
                        Image(systemName: "play.fill")
                        Text("Hear \(name) tell it")
                        Text(Duration.seconds(seconds).formatted(.time(pattern: .minuteSecond)))
                            .opacity(0.75)
                            .monospacedDigit()
                    }
                }
                .kinfolkButton(.primary)
                .padding(.top, 16)
            }

            Text(story.text)
                .font(Theme.story())
                .foregroundStyle(Theme.ink)
                .lineSpacing(6)
                .padding(.top, 18)

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
                        .paperLift(0.5)
                        .rotationEffect(.degrees(-3))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Photo of \(name). Tap to change it.")
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(Theme.ui(.title3, weight: .semibold))
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

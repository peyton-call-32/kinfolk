# Kinfolk

Kinfolk is an iPhone app that collects a grandparent's life stories, one question at a time. Family members send in questions, the grandparent answers, and every day a home screen widget on each family member's phone shows a short story or quote from them.

I built it because most family history apps ask one person to sit down and write a memoir, and most people never finish. Kinfolk splits it into small daily pieces. The family does the asking, the grandparent answers one question at a time, and everyone gets a little piece of their story each morning.

> Status: working prototype with sample stories. Accounts and sending questions to a real grandparent come next.

## What it does

- **Today.** Today's story, who told it, and the question it answers.
- **Home screen widget.** Shows the day's story on your home screen and changes just after midnight. Tapping it opens the full story in the app.
- **Ask.** Send a question to any grandparent in the family. Questions stay anonymous, so no one feels put on the spot.
- **Stories.** Every past story, grouped by month, with what it's about and who told it.
- **Family.** Every grandparent in the family with their photo. Tap one to change their name, he or she, or photo.
- **Several grandparents.** One family can follow stories from more than one grandparent.

## How it's built

Swift and SwiftUI for iOS 17, with WidgetKit for the home screen widget. The app and widget share the same story data, so the widget always matches what the app shows.

| Folder | What it does |
| --- | --- |
| `Kinfolk/Views/` | The app's screens (Today, Ask, Stories, Family) |
| `Kinfolk/FamilyStore.swift` | Everything the app shows, in one place (sample data for now) |
| `KinfolkWidget/` | The home screen widget |
| `Shared/` | Story data, colors, and fonts used by both the app and the widget |
| `project.yml` | Project setup, used to generate the Xcode project |

## Run it

Requires a Mac with Xcode 15 or newer.

1. Open `Kinfolk.xcodeproj` in Xcode.
2. Pick an iPhone simulator and press Run.
3. To see the widget, go to the simulator's home screen, press and hold, tap the plus button, and add Kinfolk.

## What's next

- Accounts, so a whole family can join one grandparent's circle
- Sending questions to the grandparent by text, since many grandparents already use iMessage

import SwiftUI

struct FamilyView: View {
    @Environment(FamilyStore.self) private var store

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ScreenHeader(title: "Family",
                             subtitle: "Everyone here sees the same story each day.") {
                    ShareLink(item: "Come read our grandparents' stories with us on Kinfolk.") {
                        Text("Invite someone")
                    }
                    .kinfolkButton(.primary, compact: true)
                }
                .padding(.horizontal, 8)

                section("Grandparents", rows: Family.grandparents.map {
                    ($0.name, countText(store.storyCount(for: $0), noun: "story", plural: "stories", none: "No stories yet"))
                })
                ForEach(FamilyMember.Group.allCases, id: \.self) { group in
                    section(group.rawValue, rows: store.members.filter { $0.group == group }.map {
                        ($0.name, countText(store.questionCount(for: $0), noun: "question", plural: "questions", none: "No questions yet"))
                    })
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 24)
        }
        .waveBackdrop()
    }

    private func section(_ title: String, rows: [(name: String, detail: String)]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(text: title)
            ForEach(rows, id: \.name) { row in
                if row.name != rows.first?.name { Rule() }
                HStack {
                    Text(row.name)
                        .font(Theme.ui(.body))
                        .foregroundStyle(Theme.ink)
                    Spacer()
                    Text(row.detail)
                        .font(Theme.ui(.subheadline))
                        .foregroundStyle(Theme.inkSoft)
                }
                .frame(minHeight: 56)
            }
        }
        .padding(.horizontal, 18)
        .onSheet()
        .padding(.bottom, 20)
    }

    private func countText(_ count: Int, noun: String, plural: String, none: String) -> String {
        switch count {
        case 0: none
        case 1: "1 \(noun)"
        default: "\(count) \(plural)"
        }
    }
}

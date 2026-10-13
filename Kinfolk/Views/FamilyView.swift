import PhotosUI
import SwiftUI

struct FamilyView: View {
    @Environment(FamilyStore.self) private var store
    @State private var editing: Grandparent?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ScreenHeader(title: "Family",
                             subtitle: "Everyone here sees the same story each day.") {
                    ShareLink(item: "Come read our grandparents' stories with us on Kinfolk.") {
                        ArrowLabel(title: "Invite someone")
                    }
                    .kinfolkButton(.primary)
                }

                grandparents
                ForEach(FamilyMember.Group.allCases, id: \.self) { group in
                    // No question counts here: questions are anonymous.
                    section(group.rawValue, rows: store.members.filter { $0.group == group }.map { ($0.name, "") })
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .sheet(item: $editing) { grandparent in
            EditGrandparentView(grandparent: grandparent)
        }
    }

    /// Each grandparent with their photo. Tap one to change their name or photo.
    private var grandparents: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(text: "Grandparents")
            ForEach(Family.grandparents) { grandparent in
                if grandparent.id != Family.grandparents.first?.id { Rule() }
                Button { editing = grandparent } label: {
                    HStack(spacing: 14) {
                        Avatar(grandparent: grandparent, size: 40)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(grandparent.name)
                                .font(Theme.ui(.body))
                                .foregroundStyle(Theme.ink)
                            Text(countText(store.storyCount(for: grandparent), noun: "story", plural: "stories", none: "No stories yet"))
                                .font(Theme.ui(.subheadline))
                                .foregroundStyle(Theme.inkSoft)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.inkSoft)
                    }
                    .frame(minHeight: 64)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityHint("Edit name and photo")
            }
        }
        .padding(.horizontal, 18)
        .onSheet()
        .padding(.bottom, 20)
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

/// A round photo of a grandparent, or their initial if there's no photo yet.
struct Avatar: View {
    let grandparent: Grandparent
    let size: CGFloat
    @Environment(FamilyStore.self) private var store

    var body: some View {
        Group {
            if let photo = store.photos[grandparent.id] {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
            } else {
                Text(grandparent.name.split(separator: " ").last.map { String($0.prefix(1)) } ?? "")
                    .font(Theme.display(size * 0.45, relativeTo: .title))
                    .foregroundStyle(Theme.accent)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Theme.paper)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().strokeBorder(Theme.line, lineWidth: 1))
    }
}

/// Change a grandparent's name, he or she, and photo.
struct EditGrandparentView: View {
    let grandparent: Grandparent
    @Environment(FamilyStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var his: String
    @State private var photoItem: PhotosPickerItem?

    init(grandparent: Grandparent) {
        self.grandparent = grandparent
        _name = State(initialValue: grandparent.name)
        _his = State(initialValue: grandparent.his)
    }

    private var trimmedName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var hasPhoto: Bool { store.photos[grandparent.id] != nil }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 14) {
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        Avatar(grandparent: Grandparent(id: grandparent.id, name: trimmedName, his: his), size: 112)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(hasPhoto ? "Change photo" : "Add a photo")

                    HStack(spacing: 10) {
                        PhotosPicker(selection: $photoItem, matching: .images) {
                            Text(hasPhoto ? "Change photo" : "Add photo")
                        }
                        .kinfolkButton(.secondary, compact: true)
                        if hasPhoto {
                            Button("Remove") { store.removePhoto(for: grandparent.id) }
                                .kinfolkButton(.secondary, compact: true)
                        }
                    }
                }
                .padding(.top, 4)

                VStack(alignment: .leading, spacing: 0) {
                    SectionLabel(text: "Name")
                    TextField("What the family calls them", text: $name)
                        .font(Theme.ui(.body))
                        .foregroundStyle(Theme.ink)
                        .textInputAutocapitalization(.words)
                        .frame(minHeight: 48)
                    Rule()
                    SectionLabel(text: "Tell their stories as")
                    HStack(spacing: 8) {
                        pronounButton("He", value: "his")
                        pronounButton("She", value: "her")
                    }
                    .padding(.bottom, 18)
                }
                .padding(.horizontal, 18)
                .onSheet()

                Button {
                    Family.rename(grandparent.id, to: trimmedName, his: his)
                    dismiss()
                } label: { Text("Save") }
                    .kinfolkButton(.primary)
                    .disabled(trimmedName.isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(Theme.paper.ignoresSafeArea())
        .safeAreaInset(edge: .top, spacing: 0) {
            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                    .kinfolkButton(.secondary, compact: true)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
        }
        .presentationDragIndicator(.visible)
        .onChange(of: photoItem) {
            Task {
                if let data = try? await photoItem?.loadTransferable(type: Data.self) {
                    store.setPhoto(data, for: grandparent.id)
                }
            }
        }
    }

    private func pronounButton(_ title: String, value: String) -> some View {
        Button(title) { his = value }
            .kinfolkButton(his == value ? .selected : .secondary, compact: true)
    }
}

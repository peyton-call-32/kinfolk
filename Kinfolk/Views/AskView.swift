import SwiftUI

struct AskView: View {
    @Environment(FamilyStore.self) private var store
    @FocusState private var focused: Bool

    var body: some View {
        @Bindable var store = store
        let canSend = !store.draftQuestion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let target = Family.grandparent(store.askTarget ?? Family.grandparents[0].id)

        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ScreenHeader(title: "Ask a question",
                             subtitle: "Everyone in the family sees the answer.") {
                    ChipRow(options: ChipOption.grandparents, selection: $store.askTarget)
                }
                .padding(.horizontal, 8)

                TextField("", text: $store.draftQuestion,
                          prompt: Text("What do you want to ask \(target.name)?")
                              .foregroundStyle(Theme.inkSoft),
                          axis: .vertical)
                    .font(Theme.ui(.title3))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(4...8)
                    .focused($focused)
                    .padding(18)
                    .onSheet()

                Button {
                    withAnimation(.snappy) { store.sendDraft() }
                    focused = false
                } label: {
                    Text("Send to \(target.name)")
                        .frame(maxWidth: .infinity)
                }
                .kinfolkButton(canSend ? .primary : .secondary)
                .disabled(!canSend)
                .padding(.top, 16)

                if !store.waitingQuestions.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        SectionLabel(text: "Waiting for an answer")
                        ForEach(store.waitingQuestions) { question in
                            if question.id != store.waitingQuestions.first?.id { Rule() }
                            VStack(alignment: .leading, spacing: 4) {
                                Text("To \(Family.grandparent(question.grandparentID).name)")
                                    .font(Theme.ui(.footnote))
                                    .foregroundStyle(Theme.inkSoft)
                                Text(question.text)
                                    .font(Theme.question(17, relativeTo: .body))
                                    .foregroundStyle(Theme.ink)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 14)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 18)
                    .onSheet()
                    .padding(.top, 28)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 24)
        }
        .waveBackdrop()
        .scrollDismissesKeyboard(.interactively)
    }
}

import SwiftUI

struct FamilyMember: Identifiable {
    enum Group: String, CaseIterable {
        case kids = "Kids", grandkids = "Grandkids"
    }

    let name: String
    let group: Group
    var id: String { name }
}

struct WaitingQuestion: Identifiable {
    let id = UUID()
    let grandparentID: String
    let text: String
}

/// Everything the app shows, in one place. Sample data for now.
@Observable
final class FamilyStore {
    var stories: [Story] = SampleStories.all.sorted { $0.answeredDaysAgo < $1.answeredDaysAgo }
    var members: [FamilyMember] =
        ["Dad", "Mom", "Aunt Marci", "Uncle Steve"].map { FamilyMember(name: $0, group: .kids) } +
        ["Josh", "Brynn", "Kade", "Hallie"].map { FamilyMember(name: $0, group: .grandkids) }
    var waitingQuestions: [WaitingQuestion] = []
    var draftQuestion = ""
    /// Which grandparent the Ask screen sends to.
    var askTarget: String? = Family.grandparents.first?.id
    var photos: [String: UIImage] = FamilyStore.loadPhotos()

    func storyCount(for grandparent: Grandparent) -> Int {
        stories.filter { $0.grandparentID == grandparent.id }.count
    }

    func sendDraft() {
        let text = draftQuestion.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, let target = askTarget else { return }
        waitingQuestions.insert(WaitingQuestion(grandparentID: target, text: text), at: 0)
        draftQuestion = ""
    }

    // MARK: Photos, saved on this phone

    private static func photoURL(_ grandparentID: String) -> URL {
        URL.documentsDirectory.appending(path: "photo-\(grandparentID).jpg")
    }

    private static func loadPhotos() -> [String: UIImage] {
        var photos: [String: UIImage] = [:]
        for grandparent in Family.grandparents {
            if let data = try? Data(contentsOf: photoURL(grandparent.id)), let image = UIImage(data: data) {
                photos[grandparent.id] = image
            }
        }
        return photos
    }

    func setPhoto(_ data: Data, for grandparentID: String) {
        guard let image = UIImage(data: data) else { return }
        photos[grandparentID] = image
        try? image.jpegData(compressionQuality: 0.85)?.write(to: Self.photoURL(grandparentID))
    }

    func removePhoto(for grandparentID: String) {
        photos[grandparentID] = nil
        try? FileManager.default.removeItem(at: Self.photoURL(grandparentID))
    }
}

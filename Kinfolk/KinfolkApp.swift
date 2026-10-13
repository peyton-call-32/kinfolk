import SwiftUI

@main
struct KinfolkApp: App {
    @State private var store = FamilyStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
        }
    }
}

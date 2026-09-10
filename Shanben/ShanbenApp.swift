import SwiftData
import SwiftUI

@main
struct ShanbenApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .preferredColorScheme(.light)
        }
        .modelContainer(for: Deed.self)
    }
}

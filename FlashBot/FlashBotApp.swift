import SwiftUI

@main
struct FlashBotApp: App {
    
    // @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

import SwiftUI

struct ContentView: View {

    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        ZStack {
            TabView {
                LessonListView()
                .tabItem {
                    Label("Lessons", systemImage: "list.dash")
                }
                SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "list.dash")
                }
            }
            .accentColor(Color("AccentColor"))
            .onOpenURL { url in
                print("Incoming url: \(url)")
            }
            .onChange(of: scenePhase) { newScenePhase in
                switch newScenePhase {
                case .background:
                    print("App State : Background")
                case .inactive:
                    print("App State : Inactive")
                case .active:
                    print("App State : Active")
                @unknown default:
                    print("App State : Unknown")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

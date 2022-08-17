import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            LessonListView()
                .tabItem {
                    Label("Menu", systemImage: "list.dash")
                }
            SettingsView()
                .tabItem{
                    Label("Text", systemImage: "list.dash")
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

import SwiftUI

struct SettingsView: View {

    @State private var name = ""

    var body: some View {
        Form {
            Section {
                Text("Hello, World!")
            }
            Section {
                TextField("Enter your name", text: $name)
                Text("Hello, \(name)!")
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

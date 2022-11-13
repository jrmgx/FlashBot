import SwiftUI

struct LessonDetailToolbarButtonPrimary: View {

    var actionAdd: (() -> Void)?
    var actionTranslate: (() -> Void)?
    var actionSettings: (() -> Void)?

    @State private var showingAlert = false

    var body: some View {
        Button("...") {
            showingAlert = true
        }
        .alert("Actions", isPresented: $showingAlert) {
            if let actionAdd = actionAdd {
                Button("Add", action: actionAdd)
            }
            if let actionTranslate = actionTranslate {
                Button("Translate", action: actionTranslate)
            }
            if let actionSettings = actionSettings {
                Button("Settings", action: actionSettings)
            }
            Button("Cancel") { }
        }
    }
}

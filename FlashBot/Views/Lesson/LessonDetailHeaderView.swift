import SwiftUI

struct LessonDetailHeaderView: View {

    var title: String
    var actionAdd: (() -> Void)?
    var actionTranslate: (() -> Void)?
    var actionSettings: (() -> Void)?

    @State private var showingAlert = false

    var body: some View {
        HStack {
            Spacer()
            Text(title)
            .font(.headline)
            .padding(.leading, -10)
            Spacer()
            Button("...") {
                showingAlert = true
            }
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

struct LessonDetailHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LessonDetailHeaderView(title: "Lesson 1")
        }
        .previewLayout(.fixed(width: 300, height: 50))
    }
}

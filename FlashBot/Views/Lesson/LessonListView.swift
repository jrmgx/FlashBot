import SwiftUI

struct LessonListView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var body: some View {
        NavigationView {
            List(FakeData.LessonList(viewContext: managedObjectContext)) { lesson in
                NavigationLink {
                    LessonDetailView(lesson: lesson)
                } label: {
                    LessonRowView(lesson: lesson)
                }
            }
        }
        .navigationTitle("Lessons")
    }
}

struct LessonListView_Previews: PreviewProvider {
    static var previews: some View {
        LessonListView()
    }
}

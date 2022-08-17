import SwiftUI
import CoreData

struct LessonListView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.lastPlayedAt)
    ]) var lessons: FetchedResults<Lesson>

    var body: some View {
        NavigationView {
            VStack {
//                Button("ok") {
//                    let l = Lesson(context: managedObjectContext)
//                    l.id = UUID()
//                    l.title = "Random \(Date.now)"
//                    try? managedObjectContext.save()
//                }
                List(lessons) { lesson in
                    NavigationLink {
                        LessonDetailView(lesson: lesson)
                    } label: {
                        LessonRowView(lesson: lesson)
                    }
                }
            }
        }
        .navigationTitle("Lessons")
    }
}

struct LessonListView_Previews: PreviewProvider {
    static var previews: some View {
        LessonListView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

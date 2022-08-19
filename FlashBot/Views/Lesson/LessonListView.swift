import SwiftUI
import CoreData

struct LessonListView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.lastPlayedAt, order: .reverse)]) var lessons: FetchedResults<Lesson>
    @State private var isShowingDetailView = false
    
    var body: some View {
        NavigationView {
            VStack {
                List(lessons) { lesson in
                    NavigationLink {
                        LessonDetailView(lesson: lesson)
                    } label: {
                        LessonRowView(lesson: lesson)
                    }
                }
                NavigationLink(
                    destination: LessonDetailView(lesson: Lesson.nouveau(context: managedObjectContext)),
                    isActive: $isShowingDetailView
                ) {
                    EmptyView()
                }
                Button("New Lesson") {
                    isShowingDetailView = true
                }
            }
        }
        .navigationTitle("Lessons")
    }
}

struct LessonListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LessonListView()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            LessonListView()
        }
    }
}

import SwiftUI
import CoreData

struct LessonListView: View {

    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.lastPlayedAtInternal, order: .reverse)
    ]) var lessons: FetchedResults<Lesson>
    @State private var isShowingDetailView = false

    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: nil) {
                List(lessons) { lesson in
                    NavigationLink {
                        LessonDetailView(lesson: lesson)
                    } label: {
                        LessonRowView(lesson: lesson)
                    }
                }
                .background(.red)
                NavigationLink(
                    destination: LessonDetailView(lesson: Lesson.create(context: managedObjectContext)),
                    isActive: $isShowingDetailView
                ) {
                    EmptyView()
                }
                Button("New Lesson") {
                    isShowingDetailView = true
                }
                .padding()
            }
            .background(.red)
        }
        .onAppear {
            UITableView.appearance().separatorStyle = .none
            UITableViewCell.appearance().backgroundColor = .green
            UITableView.appearance().backgroundColor = .green
        }
        .background(.blue)
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

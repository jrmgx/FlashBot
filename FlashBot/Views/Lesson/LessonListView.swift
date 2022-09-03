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
                if !lessons.isEmpty {
                    List(lessons) { lesson in
                        NavigationLink {
                            LessonDetailView(lesson: lesson)
                        } label: {
                            LessonRowView(lesson: lesson)
                        }
                    }
                }
                NavigationLink(
                    destination: LessonDetailView(lesson: Lesson.create(context: managedObjectContext)),
                    isActive: $isShowingDetailView
                ) {
                    EmptyView()
                }
                if lessons.isEmpty {
                    Image("AvatarDefault")
                }
                Button("New Lesson") {
                    isShowingDetailView = true
                }
                .padding()
            }
            .background(Color("Background"))
        }
        .onAppear {
            // TODO could move this line
            UITableView.appearance().backgroundColor = .clear
//            if FlashBotApp.isDebug {
//                UITableView.appearance().separatorStyle = .none
//                UITableViewCell.appearance().backgroundColor = .green
//                UITableView.appearance().backgroundColor = .green
//            } else {
//                // UITableView.appearance().backgroundColor = .orange
//            }
        }
        // .background(.blue)
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

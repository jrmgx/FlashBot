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
                    HStack(alignment: .top, spacing: 100) {
                        Spacer()
                        Image("LogoTransparent")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100, alignment: .top)
                        Spacer()
                    }
                    List(lessons) { lesson in
                        NavigationLink {
                            LessonDetailView(lesson: lesson)
                        } label: {
                            LessonRowView(lesson: lesson)
                        }
                    }
                    .background(lessons.isEmpty ? .clear : Color("Background"))
                }
                NavigationLink(
                    destination: LessonDetailView(lesson: Lesson.create(context: managedObjectContext)),
                    isActive: $isShowingDetailView)
                {
                    EmptyView()
                }
                if lessons.isEmpty {
                    Image("LogoTransparent")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                }
                Button("Create a new lesson") {
                    isShowingDetailView = true
                }
                .padding()
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

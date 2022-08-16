import SwiftUI

struct LessonListView: View {
    var lessonDataFake: [Lesson] = []
    var body: some View {
        NavigationView {
            List(lessonDataFake) { lesson in
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

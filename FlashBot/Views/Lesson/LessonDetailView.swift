import SwiftUI

struct LessonDetailView: View {
    var lesson: Lesson
    var body: some View {
        //ScrollView {
        //    Text(lesson.title)
            ChatItemListView()
        //}
        .navigationTitle(lesson.title ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LessonDetailView_Previews: PreviewProvider {
    static var lessonDataFake: [Lesson] = []
    static var previews: some View {
        LessonDetailView(lesson: lessonDataFake[1])
    }
}

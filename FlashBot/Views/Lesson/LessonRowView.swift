import SwiftUI

struct LessonRowView: View {
    var lesson: Lesson
    var body: some View {
        Text(lesson.title ?? "")
    }
}

struct LessonView_Previews: PreviewProvider {
    static var lessonDataFake: [Lesson] = []
    static var previews: some View {
        Group {
            LessonRowView(lesson: lessonDataFake[0])
            LessonRowView(lesson: lessonDataFake[1])
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}

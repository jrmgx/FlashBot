import SwiftUI

struct LessonRowView: View {
    
    var lesson: Lesson
    
    var body: some View {
        Text(lesson.title ?? "")
    }
}

struct LessonView_Previews: PreviewProvider {
    
    static var previewViewContext = PersistenceController.preview.container.viewContext
    
    static var previews: some View {
        Group {
            LessonRowView(lesson: FakeData.LessonList(viewContext: previewViewContext)[0])
            LessonRowView(lesson: FakeData.LessonList(viewContext: previewViewContext)[1])
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}

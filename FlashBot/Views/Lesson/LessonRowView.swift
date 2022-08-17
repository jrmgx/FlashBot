import SwiftUI

struct LessonRowView: View {
    
    var lesson: Lesson
    
    var body: some View {
        Text(lesson.title ?? "")
    }
}

struct LessonView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            LessonRowView(lesson: PersistenceController.preview.fakeLessons[0])
            LessonRowView(lesson: PersistenceController.preview.fakeLessons[1])
        }
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .previewLayout(.fixed(width: 300, height: 70))
    }
}

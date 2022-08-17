import SwiftUI

struct LessonDetailView: View {
    
    var lesson: Lesson
    
    var body: some View {
        //ScrollView {
        //    Text(lesson.title)
            ChatItemListView(lesson: lesson)
        //}
        .navigationTitle(lesson.title ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LessonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LessonDetailView(lesson: PersistenceController.preview.fakeLessons[0])
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

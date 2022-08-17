import SwiftUI

struct ChatItemListView: View {
    
    var lesson: Lesson

//    @FetchRequest(sortDescriptors: [
//        SortDescriptor(\.postedAt, order: .reverse)
//    ]) var chatItems: FetchedResults<ChatItem>
    
    var body: some View {
        List(lesson.safeChatItems) { chatItem in
            ChatItemRowView(chatItem: chatItem)
        }
    }
}

struct ChatItemListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatItemListView(lesson: PersistenceController.preview.fakeLessons[0])
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

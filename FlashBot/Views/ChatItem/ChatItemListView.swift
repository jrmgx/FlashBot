import SwiftUI

struct ChatItemListView: View {
    
    @StateObject var lesson: Lesson

    /// @TODO how not to load the full chat items?
//    @FetchRequest(sortDescriptors: [
//        SortDescriptor(\.postedAt, order: .reverse)
//    ]) var chatItems: FetchedResults<ChatItem>

    var body: some View {
        
        ScrollViewReader { scrollViewProxy in
            List(lesson.safeChatItems) { chatItem in
                ChatItemRowView(chatItem: chatItem).id(chatItem.id)
            }
            .onReceive(lesson.objectWillChange) { _ in
                guard !lesson.safeChatItems.isEmpty else { return }
                Task {
                    scrollViewProxy.scrollTo(lesson.safeChatItems.last!.id, anchor: .top)
                }
            }
        }
    }
}

struct ChatItemListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ChatItemListView(lesson: PersistenceController.preview.fakeLessons[0])
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            ChatItemListView(lesson: Lesson())
        }
    }
}

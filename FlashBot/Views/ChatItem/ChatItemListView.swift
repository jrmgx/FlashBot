import SwiftUI

struct ChatItemListView: View {
    
    var chatItems: [ChatItem]

//    @FetchRequest(sortDescriptors: [
//        SortDescriptor(\.postedAt, order: .reverse)
//    ]) var chatItems: FetchedResults<ChatItem>
    
    var body: some View {
        ScrollView {
            ScrollViewReader { scrollViewProxy in
                LazyVStack {
                    ForEach(chatItems) { chatItem in
                        ChatItemRowView(chatItem: chatItem)
                    }
                }
                .onAppear {
                    print("on appear")
                    //withAnimation(Animation.easeInOut) {
                    guard !chatItems.isEmpty else { return }
                    scrollViewProxy.scrollTo(chatItems.last, anchor: .top)
                    //}
                }
//                .onReceive(viewModel.$discussion) { _ in
//                    guard !viewModel.discussion.isEmpty else { return }
//
//                    withAnimation(Animation.easeInOut) {
//                        sp.scrollTo(viewModel.discussion.last!.uuid)
//                    }
//                }
            }
        }
    }
}

struct ChatItemListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ChatItemListView(chatItems: PersistenceController.preview.fakeLessons[0].safeChatItems)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            ChatItemListView(chatItems: [ChatItem]())
        }
    }
}

import SwiftUI

struct ChatItemListView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var body: some View {
        List(FakeData.ChatItemList(viewContext: managedObjectContext)) { chatItem in
            ChatItemRowView(chatItem: chatItem)
        }
    }
}

struct ChatItemListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatItemListView()
    }
}

import SwiftUI

struct ChatItemListView: View {
    var body: some View {
        List(chatItemDataFake) { chatItem in
            ChatItemRowView(chatItem: chatItem)
        }
    }
}

struct ChatItemListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatItemListView()
    }
}

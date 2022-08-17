import SwiftUI

struct ChatItemRowView: View {
    
    var chatItem: ChatItem
    
    var body: some View {
        if chatItem.from {
            HStack {
                Text(chatItem.safeContent)
                    .colorInvert()
                    .padding()
                    .background(.blue)
                Spacer()
            }
        } else {
            HStack {
                Spacer()
                Text(chatItem.safeContent)
                    .padding()
                    .background(.gray)
            }
        }
    }
}

struct ChatItemRowView_Previews: PreviewProvider {
    
    static var previewViewContext = PersistenceController.preview.container.viewContext
    
    static var previews: some View {
        Group {
            ChatItemRowView(chatItem: FakeData.ChatItemList(viewContext: previewViewContext)[1])
            ChatItemRowView(chatItem: FakeData.ChatItemList(viewContext: previewViewContext)[2])
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}

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
    
    static var previews: some View {
        Group {
            ChatItemRowView(chatItem: PersistenceController.preview.fakeChatItems[0])
            ChatItemRowView(chatItem: PersistenceController.preview.fakeChatItems[2])
        }
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .previewLayout(.fixed(width: 300, height: 70))
    }
}

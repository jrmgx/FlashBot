import SwiftUI

struct ChatItemRowView: View {
    
    @StateObject var chatItem: ChatItem
    
    var body: some View {
        switch chatItem.type {
        case .unknown:
            EmptyView()
        case .basicBot:
            HStack {
                Text(chatItem.content)
                    .colorInvert()
                    .padding()
                    .background(.blue)
                Spacer()
            }
        case .basicUser:
            HStack {
                Spacer()
                Text(chatItem.content)
                    .padding()
                    .background(.gray)
            }
        case .actionButtonsUser:
            HStack {
                Spacer()
                Text("TODO BUTTON \(chatItem.content)")
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

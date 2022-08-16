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
    static var chatItemDataFake: [ChatItem] = []
    static var previews: some View {
        Group {
            ChatItemRowView(chatItem: chatItemDataFake[1])
            ChatItemRowView(chatItem: chatItemDataFake[2])
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}

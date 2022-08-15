import SwiftUI

struct ChatItemRowView: View {
    var chatItem: ChatItemModel
    var body: some View {
        if chatItem.fromBot {
            HStack {
                Text(chatItem.content)
                    .colorInvert()
                    .padding()
                    .background(.blue)
                Spacer()
            }
        } else {
            HStack {
                Spacer()
                Text(chatItem.content)
                    .padding()
                    .background(.gray)
            }
        }
    }
}

struct ChatItemRowView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ChatItemRowView(chatItem: chatItemDataFake[1])
            ChatItemRowView(chatItem: chatItemDataFake[2])
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}

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
                .lineLimit(nil)
                .foregroundColor(Color("ChatTextBot"))
                .padding()
                .background(Color("ChatBubbleBot"))
                .cornerRadius(25)
                Spacer()
            }
        case .basicUser:
            HStack {
                Spacer()
                Text(chatItem.content)
                .lineLimit(nil)
                .foregroundColor(Color("ChatTextUser"))
                .padding()
                .background(Color("ChatBubbleUser"))
                .cornerRadius(25)
            }
        case .actionButtonsUser:
            HStack {
                Spacer()
                HStack {
                    ForEach(chatItem.choices) { choice in
                        Button(choice.name) {
                            print("ok choice \(choice) button: \(self)")
                            choice.action(choice)
                        }
                        // https://www.hackingwithswift.com/quick-start/swiftui/how-to-disable-the-overlay-color-for-images-inside-button-and-navigationlink
                        .buttonStyle(PlainButtonStyle())
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(.background)
                        .cornerRadius(12.5)
                    }
                }
                .padding()
                .background(Color("ChatBubbleUser"))
                .cornerRadius(25)
            }
        }
    }
}

struct ChatItemRowView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            ChatItemRowView(chatItem: PersistenceController.preview.fakeChatItems[0])
            ChatItemRowView(chatItem: PersistenceController.preview.fakeChatItems[2])
            ChatItemRowView(chatItem: PersistenceController.preview.fakeChatItems[3])
        }
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .previewLayout(.fixed(width: 300, height: 150))
    }
}

import Foundation

func chatItemLoadDataFake() -> [ChatItemModel] {
    return [
        ChatItemModel(id: 1, fromBot: true, date: Date.now, content: "Welcome", type: 1),
        ChatItemModel(id: 2, fromBot: true, date: Date.now, content: "First message", type: 1),
        ChatItemModel(id: 3, fromBot: false, date: Date.now, content: "Moi de même", type: 1),
    ]
}

var chatItemDataFake: [ChatItemModel] = chatItemLoadDataFake()

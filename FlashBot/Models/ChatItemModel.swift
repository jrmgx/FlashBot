import Foundation

struct ChatItemModel: Codable, Hashable, Identifiable {
    var id: Int
    var fromBot: Bool
    var date: Date
    var content: String
    var type: Int
}

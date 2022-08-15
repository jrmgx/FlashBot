import Foundation

struct LessonModel: Hashable, Codable, Identifiable {
    var id: Int
    var title: String
    var data: String
    var history: [ChatItemModel]
    var stats: String
}

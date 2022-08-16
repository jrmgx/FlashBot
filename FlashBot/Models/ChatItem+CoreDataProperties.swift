import Foundation
import CoreData


extension ChatItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChatItem> {
        return NSFetchRequest<ChatItem>(entityName: "ChatItem")
    }

    @NSManaged public var content: String?
    @NSManaged public var from: Bool
    @NSManaged public var id: UUID?
    @NSManaged public var postedAt: Date?
    @NSManaged public var type: Int16
    @NSManaged public var lesson: Lesson?

    public var safeContent: String {
        content ?? ""
    }
    
}

extension ChatItem : Identifiable {

}

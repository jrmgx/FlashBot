import Foundation
import CoreData


extension ChatItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChatItem> {
        return NSFetchRequest<ChatItem>(entityName: "ChatItem")
    }
    
    @nonobjc public class func fetchRequest100() -> NSFetchRequest<ChatItem> {
        // return NSFetchRequest<ChatItem>(entityName: "ChatItem")
        let request: NSFetchRequest<ChatItem> = ChatItem.fetchRequest()
        request.fetchLimit = 100
        return request
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
    
    public var safeFrom: Bool {
        from
    }
        
    public var safePostedAt: Date {
        postedAt ?? Date.now
    }
    
    public var safeType: Int16 {
        type
    }
}

extension ChatItem : Identifiable {

}

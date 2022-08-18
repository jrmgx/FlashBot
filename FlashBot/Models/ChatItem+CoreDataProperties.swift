import Foundation
import CoreData


extension ChatItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChatItem> {
        return NSFetchRequest<ChatItem>(entityName: "ChatItem")
    }
    
    @nonobjc public class func fetchRequest100() -> NSFetchRequest<ChatItem> {
        let request: NSFetchRequest<ChatItem> = ChatItem.fetchRequest()
        request.fetchLimit = 100
        return request
    }

    @NSManaged public var content: String?
    @NSManaged public var fromBot: Bool
    @NSManaged public var id: UUID?
    @NSManaged public var postedAt: Date?
    @NSManaged public var type: Int16
    @NSManaged public var lesson: Lesson?

    @nonobjc public class func nouveau(context: NSManagedObjectContext) -> ChatItem {
        let cc = ChatItem(context: context)
        cc.id = UUID()
        cc.fromBot = true
        cc.postedAt = Date.now
        cc.type = 1
        return cc
    }
    
    public var safeContent: String {
        get { content ?? "" }
    }
    
    public var safeFromBot: Bool {
        get { fromBot }
    }
        
    public var safePostedAt: Date {
        get { postedAt ?? Date.now }
    }
    
    public var safeType: Int16 {
        get { type }
    }
}

extension ChatItem : Identifiable {

}

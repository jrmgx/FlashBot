import Foundation
import CoreData

public enum ChatItemType: Int16 {
    case unknown
    case basicBot
    case basicUser
    case actionButtonsUser
}

extension ChatItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChatItem> {
        return NSFetchRequest<ChatItem>(entityName: "ChatItem")
    }
    
    @nonobjc public class func fetchRequest100() -> NSFetchRequest<ChatItem> {
        let request: NSFetchRequest<ChatItem> = ChatItem.fetchRequest()
        request.fetchLimit = 100
        return request
    }

    @NSManaged public var content_: String?
    @NSManaged public var fromBot_: Bool
    @NSManaged public var id_: UUID?
    @NSManaged public var postedAt_: Date?
    @NSManaged public var type_: Int16
    @NSManaged public var lesson_: Lesson?

    @nonobjc public class func create(context: NSManagedObjectContext) -> ChatItem {
        let chatItem = ChatItem(context: context)
        chatItem.id_ = UUID()
        chatItem.postedAt_ = Date.now
        chatItem.type_ = ChatItemType.basicBot.rawValue
        return chatItem
    }
    
    public var content: String {
        get { content_ ?? "" }
        set { content_ = newValue }
    }
        
    public var postedAt: Date {
        get { postedAt_ ?? Date.now }
        set { postedAt_ = newValue }
    }
    
    public var type: ChatItemType {
        get { ChatItemType.init(rawValue: type_) ?? ChatItemType.unknown }
        set { type_ = newValue.rawValue }
    }
}

extension ChatItem : Identifiable {

}

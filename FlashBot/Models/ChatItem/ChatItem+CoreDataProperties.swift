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

    @NSManaged public var contentInternal: String?
    @NSManaged public var fromBotInternal: Bool
    @NSManaged public var idInternal: UUID?
    @NSManaged public var postedAtInternal: Date?
    @NSManaged public var typeInternal: Int16
    @NSManaged public var lessonInternal: Lesson?

    @nonobjc public class func create(context: NSManagedObjectContext) -> ChatItem {
        let chatItem = ChatItem(context: context)
        chatItem.idInternal = UUID()
        chatItem.postedAtInternal = Date()
        chatItem.typeInternal = ChatItemType.basicBot.rawValue
        return chatItem
    }

    public var content: String {
        get { contentInternal ?? "" }
        set { contentInternal = newValue }
    }

    public var postedAt: Date {
        get { postedAtInternal ?? Date() }
        set { postedAtInternal = newValue }
    }

    public var type: ChatItemType {
        get { ChatItemType.init(rawValue: typeInternal) ?? ChatItemType.unknown }
        set { typeInternal = newValue.rawValue }
    }
}

extension ChatItem: Identifiable {

}

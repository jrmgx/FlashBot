import Foundation
import CoreData

public enum LessonSate: Int16 {
    case unknown
    case setup_presenting
    case setup_wait_for_lesson_title
    case setup_wait_for_lesson_entries
    case setup_finished
}

extension Lesson {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Lesson> {
        return NSFetchRequest<Lesson>(entityName: "Lesson")
    }

    @NSManaged public var id_: UUID?
    @NSManaged public var lastPlayedAt_: Date?
    @NSManaged public var title_: String?
    @NSManaged public var chatItems_: NSSet?
    @NSManaged public var lessonEntries_: NSSet?
    @NSManaged public var state_: Int16

    @nonobjc public class func create(context: NSManagedObjectContext) -> Lesson {
        let lesson = Lesson(context: context)
        lesson.id_ = UUID()
        lesson.lastPlayedAt_ = Date.now
        lesson.state_ = LessonSate.setup_presenting.rawValue
        return lesson
    }
    
    public func appendBotMessage(text: String) {
        guard let managedObjectContext = managedObjectContext else {
            print("Could not get managedObjectContext while appendBotMessage")
            return
        }
        
        let chatItem = ChatItem.create(context: managedObjectContext)
        chatItem.content = text
        chatItem.type = ChatItemType.basicBot
        addToChatItems(chatItem)
    }
    
    public func appendUserMessage(text: String) {
        guard let managedObjectContext = managedObjectContext else {
            print("Could not get managedObjectContext while appendBotMessage")
            return
        }
        
        let chatItem = ChatItem.create(context: managedObjectContext)
        chatItem.content = text
        chatItem.type = ChatItemType.basicUser
        addToChatItems(chatItem)
    }
    
    public var state: LessonSate {
        get { LessonSate.init(rawValue: state_) ?? LessonSate.unknown }
        set { state_ = newValue.rawValue }
    }
    
    public var lastPlayedAt: Date {
        get { lastPlayedAt_ ?? Date.now }
        set { lastPlayedAt_ = newValue }
    }
    
    public var title: String {
        get { title_ ?? "No Title" }
        set { title_ = newValue }
    }
        
    public var lessonEntries: [LessonEntry] {
        let set = lessonEntries_ as? Set<LessonEntry> ?? []
        return set.sorted {
            $0.score < $1.score
        }
    }
    
    public var chatItems: [ChatItem] {
        let set = chatItems_ as? Set<ChatItem> ?? []
        return set.sorted {
            $0.postedAt < $1.postedAt
        }
    }
    
//    override public func willChangeValue(forKey key: String) {
//        super.willChangeValue(forKey: key)
//        self.objectWillChange.send()
//    }

}

// MARK: Generated accessors for chatItems_
extension Lesson {

    public func addToChatItems(_ value: ChatItem) {
        addToChatItems_(value)
        lastPlayedAt = Date.now
    }
    
    @objc(addChatItems_Object:)
    @NSManaged public func addToChatItems_(_ value: ChatItem)

    @objc(removeChatItems_Object:)
    @NSManaged public func removeFromChatItems_(_ value: ChatItem)

    @objc(addChatItems_:)
    @NSManaged public func addToChatItems_(_ values: NSSet)

    @objc(removeChatItems_:)
    @NSManaged public func removeFromChatItems_(_ values: NSSet)

}

// MARK: Generated accessors for lessonEntries_
extension Lesson {

    @objc(addLessonEntries_Object:)
    @NSManaged public func addToLessonEntries_(_ value: LessonEntry)

    @objc(removeLessonEntries_Object:)
    @NSManaged public func removeFromLessonEntries_(_ value: LessonEntry)

    @objc(addLessonEntries_:)
    @NSManaged public func addToLessonEntries_(_ values: NSSet)

    @objc(removeLessonEntries_:)
    @NSManaged public func removeFromLessonEntries_(_ values: NSSet)

}

extension Lesson : Identifiable {

}

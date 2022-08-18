import Foundation
import CoreData

public enum LessonSate: Int16 {
    case unknown
    case setup_presenting
    case setup_wait_for_lesson_title
    case setup_wait_for_lesson_entries
}

extension Lesson {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Lesson> {
        return NSFetchRequest<Lesson>(entityName: "Lesson")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var lastPlayedAt: Date?
    @NSManaged public var title: String?
    @NSManaged public var chatItems: NSSet?
    @NSManaged public var lessonEntries: NSSet?
    @NSManaged public var state: Int16

    @nonobjc public class func nouveau(context: NSManagedObjectContext) -> Lesson {
        let l = Lesson(context: context)
        l.id = UUID()
        l.lastPlayedAt = Date.now
        l.state = LessonSate.setup_presenting.rawValue
        return l
    }
    
    public func appendBotMessage(text: String) {
        guard let managedObjectContext = managedObjectContext else {
            print("Could not get managedObjectContext while appendBotMessage")
            return
        }
        
        let c = ChatItem.nouveau(context: managedObjectContext)
        c.content = text
        c.fromBot = true
        addToChatItems(c)
    }
    
    public func appendUserMessage(text: String) {
        guard let managedObjectContext = managedObjectContext else {
            print("Could not get managedObjectContext while appendBotMessage")
            return
        }
        
        let c = ChatItem.nouveau(context: managedObjectContext)
        c.content = text
        c.fromBot = false
        addToChatItems(c)
    }
    
    public var safeSate: LessonSate {
        get { LessonSate.init(rawValue: state) ?? LessonSate.unknown }
    }
    
    public var safeLastPlayedAt: Date {
        get { lastPlayedAt ?? Date.now }
    }
    
    public var safeTitle: String {
        get { title ?? "No Title" }
    }
        
    public var safeLessonEntries: [LessonEntry] {
        let set = lessonEntries as? Set<LessonEntry> ?? []
        return set.sorted {
            $0.score < $1.score
        }
    }
    
    public var safeChatItems: [ChatItem] {
        let set = chatItems as? Set<ChatItem> ?? []
        return set.sorted {
            $0.safePostedAt < $1.safePostedAt
        }
    }
    
//    override public func willChangeValue(forKey key: String) {
//        super.willChangeValue(forKey: key)
//        self.objectWillChange.send()
//    }

}

// MARK: Generated accessors for chatItems
extension Lesson {

    @objc(addChatItemsObject:)
    @NSManaged public func addToChatItems(_ value: ChatItem)

    @objc(removeChatItemsObject:)
    @NSManaged public func removeFromChatItems(_ value: ChatItem)

    @objc(addChatItems:)
    @NSManaged public func addToChatItems(_ values: NSSet)

    @objc(removeChatItems:)
    @NSManaged public func removeFromChatItems(_ values: NSSet)

}

// MARK: Generated accessors for lessonEntries
extension Lesson {

    @objc(addLessonEntriesObject:)
    @NSManaged public func addToLessonEntries(_ value: LessonEntry)

    @objc(removeLessonEntriesObject:)
    @NSManaged public func removeFromLessonEntries(_ value: LessonEntry)

    @objc(addLessonEntries:)
    @NSManaged public func addToLessonEntries(_ values: NSSet)

    @objc(removeLessonEntries:)
    @NSManaged public func removeFromLessonEntries(_ values: NSSet)

}

extension Lesson : Identifiable {

}

import Foundation
import CoreData

extension Lesson {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Lesson> {
        return NSFetchRequest<Lesson>(entityName: "Lesson")
    }

    @NSManaged public var idInternal: UUID?
    @NSManaged public var lastPlayedAtInternal: Date?
    @NSManaged public var titleInternal: String?
    @NSManaged public var chatItemsInternal: NSSet?
    @NSManaged public var lessonEntriesInternal: NSSet?
    @NSManaged public var stateInternal: Int16
    @NSManaged public var pathInternal: String?

    @nonobjc public class func create(context: NSManagedObjectContext) -> Lesson {
        let lesson = Lesson(context: context)
        lesson.idInternal = UUID()
        lesson.lastPlayedAtInternal = Date()
        lesson.stateInternal = LessonSate.setupPresenting.rawValue
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
        get { LessonSate.init(rawValue: stateInternal) ?? LessonSate.unknown }
        set { stateInternal = newValue.rawValue }
    }

    public var lastPlayedAt: Date {
        get { lastPlayedAtInternal ?? Date() }
        set { lastPlayedAtInternal = newValue }
    }

    public var title: String {
        get { titleInternal ?? "No Title" }
        set { titleInternal = newValue }
    }

    public var path: String {
        get { pathInternal ?? "No Path" }
        set { pathInternal = newValue }
    }

    public var lessonEntries: [LessonEntry] {
        let set = lessonEntriesInternal as? Set<LessonEntry> ?? []
        return set.sorted {
            $0.score < $1.score
        }
    }

    public var chatItems: [ChatItem] {
        let set = chatItemsInternal as? Set<ChatItem> ?? []
        return set.sorted {
            $0.postedAt < $1.postedAt
        }
    }
}

// MARK: Generated accessors for chatItemsInternal
extension Lesson {

    public func addToChatItems(_ value: ChatItem) {
        addToChatItemsInternal(value)
        lastPlayedAt = Date()
    }

    @objc(addChatItemsInternalObject:)
    @NSManaged public func addToChatItemsInternal(_ value: ChatItem)

    @objc(removeChatItemsInternalObject:)
    @NSManaged public func removeFromChatItemsInternal(_ value: ChatItem)

    @objc(addChatItemsInternal:)
    @NSManaged public func addToChatItemsInternal(_ values: NSSet)

    @objc(removeChatItemsInternal:)
    @NSManaged public func removeFromChatItemsInternal(_ values: NSSet)

}

// MARK: Generated accessors for lessonEntriesInternal
extension Lesson {

    public func addToLessonEntries(_ value: LessonEntry) {
        addToLessonEntriesInternal(value)
        lastPlayedAt = Date()
    }

    @objc(addLessonEntriesInternalObject:)
    @NSManaged public func addToLessonEntriesInternal(_ value: LessonEntry)

    @objc(removeLessonEntriesInternalObject:)
    @NSManaged public func removeFromLessonEntriesInternal(_ value: LessonEntry)

    @objc(addLessonEntriesInternal:)
    @NSManaged public func addToLessonEntriesInternal(_ values: NSSet)

    @objc(removeLessonEntriesInternal:)
    @NSManaged public func removeFromLessonEntriesInternal(_ values: NSSet)

}

extension Lesson: Identifiable {

}

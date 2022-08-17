import Foundation
import CoreData


extension Lesson {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Lesson> {
        return NSFetchRequest<Lesson>(entityName: "Lesson")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var lastPlayedAt: Date?
    @NSManaged public var title: String?
    @NSManaged public var chatItems: NSSet?
    @NSManaged public var lessonEntries: NSSet?

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

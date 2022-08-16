import Foundation
import CoreData


extension Lesson {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Lesson> {
        return NSFetchRequest<Lesson>(entityName: "Lesson")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var lastPlayedAt: Date?
    @NSManaged public var title: String?
    @NSManaged public var chatItems: ChatItem?
    @NSManaged public var lessonEntries: LessonEntry?

}

extension Lesson : Identifiable {

}

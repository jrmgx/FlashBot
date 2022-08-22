import Foundation
import CoreData

extension LessonEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LessonEntry> {
        return NSFetchRequest<LessonEntry>(entityName: "LessonEntry")
    }

    @NSManaged public var idInternal: UUID?
    @NSManaged public var lastShownAtInternal: Date?
    @NSManaged public var scoreInternal: Int16
    @NSManaged public var translationInternal: String?
    @NSManaged public var wordInternal: String?
    @NSManaged public var detailsInternal: String?
    @NSManaged public var lessonInternal: Lesson?

    @nonobjc public class func create(context: NSManagedObjectContext) -> LessonEntry {
        let lessonEntry = LessonEntry(context: context)
        lessonEntry.idInternal = UUID()
        lessonEntry.lastShownAt = Date()
        return lessonEntry
    }

    public var lastShownAt: Date {
        get { lastShownAtInternal ?? Date() }
        set { lastShownAtInternal = newValue }
    }

    public var score: Int16 {
        get { scoreInternal }
        set { scoreInternal = newValue }
    }

    /// TODO add images via lesson.path + self.word path check
    public var image: String? {
        nil
    }

    public var translation: String {
        get { translationInternal ?? "Empty" }
        set { translationInternal = newValue }
    }

    public var word: String {
        get { wordInternal ?? "Empty"}
        set { wordInternal = newValue }
    }

    public var details: String? {
        get { detailsInternal }
        set { detailsInternal = newValue }
    }

}

extension LessonEntry: Identifiable {

}

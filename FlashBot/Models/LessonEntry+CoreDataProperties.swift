import Foundation
import CoreData


extension LessonEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LessonEntry> {
        return NSFetchRequest<LessonEntry>(entityName: "LessonEntry")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var lastShownAt: Date?
    @NSManaged public var score: Int16
    @NSManaged public var translation: String?
    @NSManaged public var word: String?
    @NSManaged public var lesson: Lesson?
        
    public var safeLastShownAt: Date {
        lastShownAt ?? Date.now
    }
    
    public var safeScore: Int16 {
        score
    }

    public var safeTranslation: String {
        translation ?? "Empty"
    }

    public var safeWord: String {
        word ?? "Empty"
    }

    public var safeLesson: Lesson {
        lesson ?? Lesson()
    }

}

extension LessonEntry : Identifiable {

}

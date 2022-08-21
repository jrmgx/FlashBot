import Foundation
import CoreData


extension LessonEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LessonEntry> {
        return NSFetchRequest<LessonEntry>(entityName: "LessonEntry")
    }

    @NSManaged public var id_: UUID?
    @NSManaged public var lastShownAt_: Date?
    @NSManaged public var score_: Int16
    @NSManaged public var translation_: String?
    @NSManaged public var word_: String?
    @NSManaged public var lesson_: Lesson?
        
    public var lastShownAt: Date {
        get { lastShownAt_ ?? Date.now }
        set { lastShownAt_ = newValue }
    }
    
    public var score: Int16 {
        get { score_ }
        set { score_ = newValue }
    }

    public var translation: String {
        get { translation_ ?? "Empty" }
        set { translation_ = newValue }
    }

    public var word: String {
        get { word_ ?? "Empty"}
        set { word_ = newValue }
    }

}

extension LessonEntry : Identifiable {

}

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

    /// Score from 0 to 100 (if more than 100 consider it learnt)
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

extension LessonEntry {

    /// Pick an entry from the list
    /// Picker algo:
    /// 1. Sort by lastShownAt
    /// 2. Select top thrid
    /// 3. Sort by score
    /// 4. Return one random or fail
    /// - Parameter lessonEntries: array of entries
    /// - Returns: picked or nil
    public class func pickOne(entries: [LessonEntry]) -> LessonEntry? {
        
        let byDate = entries.filter { lesson in
            lesson.score < 100
        }.sorted { lessonA, lessonB in
            lessonA.lastShownAt < lessonB.lastShownAt
        }
        guard !byDate.isEmpty else {
            return nil
        }
        let byThrid = Array(byDate[..<(max(1, byDate.count/3))])
        let byScore = byThrid.sorted { lessonA, lessonB in
            lessonA.score < lessonB.score
        }

        return byScore.randomElement()
    }
}

extension LessonEntry: Identifiable {

}

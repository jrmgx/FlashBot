import Foundation
import CoreData

struct FakeData {
    
    static func ChatItemList(viewContext: NSManagedObjectContext) -> [ChatItem] {
        
        let c1 = ChatItem(context: viewContext)
        c1.id = UUID()
        c1.from = true
        c1.content = "Hello"
        c1.postedAt = Date.now
        c1.type = 1
        c1.lesson = LessonList(viewContext: viewContext)[0]

        let c2 = ChatItem(context: viewContext)
        c2.id = UUID()
        c2.from = true
        c2.content = "Hello"
        c2.postedAt = Date.now
        c2.type = 1
        c2.lesson = LessonList(viewContext: viewContext)[0]

        let c3 = ChatItem(context: viewContext)
        c3.id = UUID()
        c3.from = true
        c3.content = "Hello"
        c3.postedAt = Date.now
        c3.type = 1
        c3.lesson = LessonList(viewContext: viewContext)[0]

        return [c1, c2, c3]
        
    }
    
    static func LessonEntryList(viewContext: NSManagedObjectContext) -> [LessonEntry] {
        
        let l1 = LessonEntry(context: viewContext)
        l1.id = UUID()
        l1.lastShownAt = Date.now
        l1.score = 0
        l1.translation = "Chat"
        l1.word = "Gato"
        l1.lesson = LessonList(viewContext: viewContext)[0]
        
        return [l1]
        
    }
    
    static func LessonList(viewContext: NSManagedObjectContext) -> [Lesson] {
        
        let l1 = Lesson(context: viewContext)
        l1.id = UUID()
        l1.lastPlayedAt = Date.now
        l1.title = "Spanish to French"
        l1.chatItems = NSSet(array: ChatItemList(viewContext: viewContext))
        l1.lessonEntries = NSSet(array: LessonEntryList(viewContext: viewContext))
        
        let l2 = Lesson(context: viewContext)
        l2.id = UUID()
        l2.lastPlayedAt = Date.now
        l2.title = "Spanish to French"
        l2.chatItems = NSSet(array: ChatItemList(viewContext: viewContext))
        l2.lessonEntries = NSSet(array: LessonEntryList(viewContext: viewContext))

        return [l1, l2]
    }
    
}

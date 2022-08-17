import CoreData

class PersistenceController: ObservableObject {
    
    static let shared = PersistenceController()
    
    var fakeLessons = [Lesson]()
    var fakeChatItems = [ChatItem]()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let chatItem1 = ChatItem(context: viewContext)
        chatItem1.id = UUID()
        chatItem1.content = "Hello"
        chatItem1.from = true
        chatItem1.postedAt = Date(timeIntervalSinceNow: 1000)
        chatItem1.type = 1
        
        let chatItem2 = ChatItem(context: viewContext)
        chatItem2.id = UUID()
        chatItem2.content = "This is a message"
        chatItem2.from = true
        chatItem2.postedAt = Date(timeIntervalSinceNow: 2000)
        chatItem2.type = 1
        
        let chatItem3 = ChatItem(context: viewContext)
        chatItem3.id = UUID()
        chatItem3.content = "Gato"
        chatItem3.from = false
        chatItem3.postedAt = Date(timeIntervalSinceNow: 3000)
        chatItem3.type = 2
        
        result.fakeChatItems = [chatItem1, chatItem2, chatItem3]
        
        let lesson1 = Lesson(context: viewContext)
        lesson1.id = UUID()
        lesson1.lastPlayedAt = Date(timeIntervalSinceNow: 500)
        lesson1.title = "Spanish => French"
        lesson1.addToChatItems(chatItem1)
        lesson1.addToChatItems(chatItem2)
        lesson1.addToChatItems(chatItem3)
        
        let lesson2 = Lesson(context: viewContext)
        lesson2.id = UUID()
        lesson2.lastPlayedAt = Date(timeIntervalSinceNow: 5000)
        lesson2.title = "Electronic"
        
        result.fakeLessons = [lesson1, lesson2]
        
        try? viewContext.save()
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "FlashBot")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /* Typical reasons for an error here include:
                    * The parent directory does not exist, cannot be created, or disallows writing.
                    * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                    * The device is out of space.
                    * The store could not be migrated to the current model version.
                    * Check the error message to determine what the actual problem was.
                    */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

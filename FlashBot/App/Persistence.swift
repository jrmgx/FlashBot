import CoreData

class PersistenceController: ObservableObject {

    static let shared = PersistenceController()

    var fakeLessons = [Lesson]()
    var fakeChatItems = [ChatItem]()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        let chatItem1 = ChatItem.create(context: viewContext)
        chatItem1.content = "Hello how are you today?\nAvec un retour de ligne."
        chatItem1.type = ChatItemType.basicBot
        chatItem1.postedAt = Date(timeIntervalSinceNow: 1000)

        let chatItem2 = ChatItem.create(context: viewContext)
        chatItem2.content = "This is a message"
        chatItem2.type = ChatItemType.basicBot
        chatItem2.postedAt = Date(timeIntervalSinceNow: 2000)

        let chatItem3 = ChatItem.create(context: viewContext)
        chatItem3.content = "I'm fine this is a Gato"
        chatItem3.type = ChatItemType.basicUser
        chatItem3.postedAt = Date(timeIntervalSinceNow: 3000)

        let chatItem4 = ChatItem.create(context: viewContext)
        chatItem4.type = ChatItemType.actionButtonsUser
        chatItem4.choices = [
            ChatItemChoice(name: "Yes") { _ in print("Yes")},
            ChatItemChoice(name: "No") { _ in print("No")},
            ChatItemChoice(name: "Maybe") { _ in print("Maybe")}
        ]
        chatItem4.postedAt = Date(timeIntervalSinceNow: 3500)

        result.fakeChatItems = [chatItem1, chatItem2, chatItem3, chatItem4]

        let lesson1 = Lesson.create(context: viewContext)
        lesson1.lastPlayedAt = Date(timeIntervalSinceNow: 500)
        lesson1.title = "Spanish => French"
        lesson1.state = LessonSate.sessionWaitForAnswer

        for index in 0..<20 {
            var chatItem = ChatItem.create(context: viewContext)
            chatItem.content = "Message \(index)"
            chatItem.type = index % 2 == 0 ? ChatItemType.basicBot : ChatItemType.basicUser
            chatItem.postedAt = Date(timeIntervalSinceNow: 500 + Double(index))
            lesson1.addToChatItems(chatItem)
        }

        lesson1.addToChatItems(chatItem1)
        lesson1.addToChatItems(chatItem2)
        lesson1.addToChatItems(chatItem3)
        // lesson1.addToChatItems(chatItem4)

        let lesson2 = Lesson.create(context: viewContext)
        lesson2.lastPlayedAt = Date(timeIntervalSinceNow: 5000)
        lesson2.title = "Electronic"

        result.fakeLessons = [lesson1, lesson2]

        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application,
            // although it may be useful during development.
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
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application,
                // although it may be useful during development.

                /* Typical reasons for an error here include:
                    * The parent directory does not exist, cannot be created, or disallows writing.
                    * The persistent store is not accessible,
                    * due to permissions or data protection when the device is locked.
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

import Foundation
import CoreData

public struct ChatItemChoice: Identifiable {
    public var id: Int {
        name.hashValue
    }
    public var name: String
    public var action: () -> ()
}

@objc(ChatItem)
public class ChatItem: NSManagedObject {
    
    public var choices = [ChatItemChoice]()

}

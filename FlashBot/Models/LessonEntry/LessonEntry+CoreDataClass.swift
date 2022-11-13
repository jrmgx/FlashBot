import Foundation
import CoreData

@objc(LessonEntry)
public class LessonEntry: NSManagedObject {
    public static let scoreEasy = 50
    public static let scoreMedium = 30
    public static let scoreHard = 10
    public static let scoreSkip = 200
}

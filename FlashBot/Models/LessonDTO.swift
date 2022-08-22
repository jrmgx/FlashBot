import Foundation

struct LessonDTO: Codable, CustomStringConvertible {
    
    let title: String
    let pathUUID: String
    let entries: [LessonEntryDTO]
    
    public var description: String {
        return "LessonDTO: \(title)\n" + entries.reduce("") { partialResult, entry in
            return partialResult + entry.description + "\n"
        }
    }
}


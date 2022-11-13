import Foundation

struct LessonEntryDTO: Codable, CustomStringConvertible {

    let status: String?
    let translation: String
    let word: String
    let details: String?

    public var description: String {
        return "LessonEntryDTO: \(word) => \(translation)"
    }
}

import Foundation
import ZIPFoundation

/* {
    "title": "Lesson title",
    "pathUUID": "UUID",
    "entries": [{
        "status": "NEW|UPDATED|DELETED",
        "translation": "String",
        "word": "String",
        "details": "Optional",
    }, ...]
} */

struct LessonEntryImport: Codable, CustomStringConvertible {
    
    let status: String
    let translation: String
    let word: String
    let details: String?
    
    public var description: String {
        return "LessonEntryImport: \(word) => \(translation)"
    }
}

struct LessonImport: Codable, CustomStringConvertible {
    
    let title: String
    let pathUUID: String
    let entries: [LessonEntryImport]
    
    public var description: String {
        return "LessonImport: \(title)\n" + entries.reduce("") { partialResult, entry in
            return partialResult + entry.description + "\n"
        }
    }
}

struct ImportBundle {
    
    /// Extract the Bundle to a temporary directory and return that path
    /// - Parameter zipfile: bundle file path
    /// - Returns: return the temporary path
    public static func unzipToTemp(zipfile: URL) throws -> URL {

        var downloadTempDirectory = try! FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        downloadTempDirectory.appendPathComponent("unzip-to-temp")
        let fileManager = FileManager()
        // Cleanup previous data
        try fileManager.removeItem(at: downloadTempDirectory)
        try fileManager.createDirectory(at: downloadTempDirectory, withIntermediateDirectories: true, attributes: nil)
        try fileManager.unzipItem(at: zipfile, to: downloadTempDirectory)

        return downloadTempDirectory
    }
    
    /// Read the lesson.json file and return the corresponding data
    /// - Parameter file: lesson.json URL from the extracted bundle
    /// - Returns: LessonImport DTO
    public static func readJson(tempDirectory: URL) throws -> LessonImport {
        
        let file = tempDirectory.appendingPathComponent("lesson.json")
        let data = try Data.init(contentsOf: file)
        let decoder = JSONDecoder()
        
        return try decoder.decode(LessonImport.self, from: data)
    }
    
    public static func saveLesson() {
        
    }
}

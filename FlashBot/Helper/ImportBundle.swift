import Foundation
import ZIPFoundation
import CoreData

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
    public static func readJson(tempDirectory: URL) throws -> LessonDTO {
        
        let file = tempDirectory.appendingPathComponent("lesson.json")
        let data = try Data.init(contentsOf: file)
        let decoder = JSONDecoder()
        
        return try decoder.decode(LessonDTO.self, from: data)
    }
    
    
    /// Save the lesson entries in the lesson (as well as related images)
    /// - Parameters:
    ///   - lessonDTO: parsed lesson DTO
    ///   - lesson: current lesson object
    public static func saveLesson(lessonDTO: LessonDTO, lesson: Lesson) throws {
        
        guard let context = lesson.managedObjectContext else {
            throw FlashBotError.generalError(message: "NSManagedConext not accessible in saveLesson")
        }
        
        lesson.path = lessonDTO.pathUUID
        // TODO Copy images into path
        
        for lessonEntryDTO in lessonDTO.entries {
            let lessonEntry = LessonEntry.create(context: context)
            lessonEntry.word = lessonEntryDTO.word
            lessonEntry.translation = lessonEntryDTO.translation
            lessonEntry.details = lessonEntryDTO.details
            lesson.addToLessonEntries_(lessonEntry)
        }
        
        try context.save()
    }
}

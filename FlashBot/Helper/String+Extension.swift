import Foundation

extension String {
    func normalize() -> String? {

       return self
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .applyingTransform(.stripDiacritics, reverse: false)
    }
}

import Foundation

extension String {
    func normalizeWithTrimSpaceLowercaseRemoveDiacritics() -> String? {

       return self
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .applyingTransform(.stripDiacritics, reverse: false)
    }
}

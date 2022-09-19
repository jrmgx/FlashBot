import Foundation

/// https://www.hackingwithswift.com/articles/108/how-to-use-regular-expressions-in-swift
extension NSRegularExpression {
    convenience init(_ pattern: String, _ options: NSRegularExpression.Options = []) {
        do {
            try self.init(pattern: pattern, options: options)
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).")
        }
    }
    
    func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return firstMatch(in: string, options: [], range: range) != nil
    }
    
    func replace(source: String, by: String) -> String {
        let range = NSRange(location: 0, length: source.utf16.count)
        return stringByReplacingMatches(in: source, range: range, withTemplate: by)
    }
}


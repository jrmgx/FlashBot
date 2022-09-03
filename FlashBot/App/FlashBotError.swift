import Foundation

enum FlashBotError: Error {
    case generalError(message: String)
    case translationError(message: String)
}

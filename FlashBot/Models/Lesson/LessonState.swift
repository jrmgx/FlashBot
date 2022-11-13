import Foundation

public enum LessonSate: Int16 {
    case unknown
    // Setup
    case setupPresenting
    case setupAskForLessonTitle
    case setupWaitForLessonTitle
    case setupAskForLessonEntries
    case setupWaitForLessonEntries
    // Session
    case sessionRestart
    case sessionCanStart
    case sessionNextQuestion
    case sessionWaitForAnswer
    case sessionRightAnswer
    case sessionWaitForFeedback
    case sessionWrongAnswer
    case sessionOver
    // Extra actions
    case addWordWaitForWord
    case askTranslationWaitForWord
    case askTranslationWaitForLang
    // Exceptional
    case exceptionalNoMoreEntries
}

func < (left: LessonSate, right: LessonSate) -> Bool {
    return left.rawValue < right.rawValue
}

func > (left: LessonSate, right: LessonSate) -> Bool {
    return left.rawValue > right.rawValue
}

func <= (left: LessonSate, right: LessonSate) -> Bool {
    return left.rawValue <= right.rawValue
}

func >= (left: LessonSate, right: LessonSate) -> Bool {
    return left.rawValue >= right.rawValue
}

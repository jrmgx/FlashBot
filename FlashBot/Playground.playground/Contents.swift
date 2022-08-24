import UIKit

print("Lessons")

struct Les: CustomStringConvertible {
    public var date = Date.now
    public var score = 0
    public var description: String {
        return "Lesson with date: \(date) and score: \(score)"
    }
}

let minute: Double = 60
let lessons = [
    Les(date: Date(timeIntervalSinceNow: 10 * minute), score: 1),
    Les(date: Date(timeIntervalSinceNow: 20 * minute), score: 5),
    Les(date: Date(timeIntervalSinceNow: 50 * minute), score: 10),
    Les(date: Date(timeIntervalSinceNow: 35 * minute), score: 15),
    Les(date: Date(timeIntervalSinceNow: 50 * minute), score: 2),
    Les(date: Date(timeIntervalSinceNow: 60 * minute), score: 3),
    Les(date: Date(timeIntervalSinceNow: 25 * minute), score: 24),
    Les(date: Date(timeIntervalSinceNow: 15 * minute), score: 40),
    Les(date: Date(timeIntervalSinceNow: 65 * minute), score: 3),
    Les(date: Date(timeIntervalSinceNow: 65 * minute), score: 100),
    Les(date: Date(timeIntervalSinceNow: 25 * minute), score: 5)
]

lessons.map { lesson in print(lesson.description) }

// print("Sorted by date")
// lessons.sorted { a, b in a.date < b.date }.map { l in print(l.description) }
//
// print("Sorted by score")
// lessons.sorted { a, b in a.score < b.score}.map { l in print(l.description) }
//
// print("Half array")
// lessons[..<(lessons.count/2)].map { l in print(l.description) }

print("Sorted by date, then score, then subselect and random")
let under100 = lessons.filter { lesson in
    lesson.score < 100
}
let byDate = under100
    .sorted { lessonA, lessonB in lessonA.date < lessonB.date }
let byHalf = Array(byDate[..<(lessons.count/2)])
let byScore = byHalf
    .sorted { lessonA, lessonB in lessonA.score < lessonB.score}

byScore.map { lesson in print(lesson.description) }

if let selected = byScore.randomElement() {
    print("Selected: \(selected.description)")
}

import Foundation

func lessonLoadDataFake() -> [LessonModel] {
    return [
        LessonModel(id: 1, title: "Spanish to French", data: "", history: [], stats: ""),
        LessonModel(id: 2, title: "Electronics", data: "", history: [], stats: "")
    ]
}

var lessonDataFake: [LessonModel] = lessonLoadDataFake()

import SwiftUI

struct LessonDetailView: View {
    
    @State private var value: String = ""
    @State private var lessonTitle = ""
    @StateObject var lesson: Lesson
    @Environment(\.managedObjectContext) var managedObjectContext

    private func validate(text: String) {
        if lesson.safeSate == .setup_wait_for_lesson_title {
            lessonTitle = text
        }
        
        lesson.appendUserMessage(text: text)
        
        value = ""
        
        try? managedObjectContext.save()
    }

    private func botNextAction() async {
        // Resolve state
        let state = lesson.safeSate
        
        // Execute action
        switch state {
        case .unknown:
            print("Unknown state for current lesson.")
        case .setup_presenting:
            await setupPresenting()
        case .setup_wait_for_lesson_title:
            await setupWaitForLessonTitle()
        case .setup_wait_for_lesson_entries:
            await setupWaitForLessonEntries()
        }
    }
    
    private func setupPresenting() async {
                
        await Waits.seconds(seconds: 0.5)
        
        lesson.appendBotMessage(text: "Hello!\nLet's configure your new lesson together.")
        await Waits.seconds(seconds: 1)
        
        lesson.appendBotMessage(text: "First of all, give your lesson a great title.")
        lesson.appendBotMessage(text: "Maybe you're learning Spanish, so it could be 'Learning Spanish'.")
        lesson.state = LessonSate.setup_wait_for_lesson_title.rawValue
        
        try? managedObjectContext.save()
        
        await botNextAction()
    }
    
    private func setupWaitForLessonTitle() async {
        
        await Waits.untilTrue { !lessonTitle.isEmpty }
        
        lesson.title = lessonTitle
        lesson.appendBotMessage(text: "Super titre!")
        lesson.state = LessonSate.setup_wait_for_lesson_entries.rawValue
        
        try? managedObjectContext.save()
        
        await botNextAction()
    }
    
    private func setupWaitForLessonEntries() async {
        
        lesson.appendBotMessage(text: "Passons à la suite ...")
        await Waits.seconds(seconds: 0.5)
        
        lesson.appendBotMessage(text: "Nous avons besoin d'un dataset, entrez en un")
        
        // lesson.state = LessonSate.setup_wait_for_lesson_title.rawValue
        // try? managedObjectContext.save()
        
        // await botNextAction()
    }
    
    var body: some View {
        VStack {
            ChatItemListView(chatItems: lesson.safeChatItems)
            HStack {
                TextField("Placeholder", text: $value)
                    .onSubmit {
                        validate(text: value)
                    }
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .border(.secondary)
                    .padding()
//                Button("IDK") {
//                    print("Button IDK")
//                }
                    //.padding()
            }
        }
        .navigationTitle(lesson.title ?? "New Lesson")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await botNextAction()
            }
        }
    }
}

struct LessonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LessonDetailView(lesson: PersistenceController.preview.fakeLessons[0])
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            LessonDetailView(lesson: Lesson(context: PersistenceController.preview.container.viewContext))
        }
    }
}

import SwiftUI

struct LessonDetailView: View {
    
    @State private var value: String = ""
    @State private var lessonTitle = ""
    @StateObject var lesson: Lesson
    @State private var showDocumentPicker = false
    @State private var fileUrl: URL? = nil
    @Environment(\.managedObjectContext) var managedObjectContext

    private func validate(text: String) {
        if lesson.state == .setup_wait_for_lesson_title {
            lessonTitle = text
        }
        
        lesson.appendUserMessage(text: text)
        
        value = ""
        
        try? managedObjectContext.save()
    }

    private func botNextAction() async {
        // Resolve state
        let state = lesson.state
        
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
        case .setup_finished:
            print("ready")
        }
    }
    
    private func setupPresenting() async {
                
        await Waits.seconds(seconds: 0.5)
        
        lesson.appendBotMessage(text: "Hello!\nLet's configure your new lesson together.")
        await Waits.seconds(seconds: 1)
        
        lesson.appendBotMessage(text: "First of all, give your lesson a great title.")
        lesson.appendBotMessage(text: "Maybe you're learning Spanish, so it could be 'Learning Spanish'.")
        lesson.state = LessonSate.setup_wait_for_lesson_title
        
        try? managedObjectContext.save()
        
        await botNextAction()
    }
    
    private func setupWaitForLessonTitle() async {
        
        await Waits.untilTrue { !lessonTitle.isEmpty }
        
        lesson.title = lessonTitle
        lesson.appendBotMessage(text: "Super titre!")
        lesson.state = LessonSate.setup_wait_for_lesson_entries
        
        try? managedObjectContext.save()
        
        await botNextAction()
    }
    
    private func setupWaitForLessonEntries() async {
        
        lesson.appendBotMessage(text: "Passons à la suite ...")
        await Waits.seconds(seconds: 0.5)
        
        lesson.appendBotMessage(text: "Nous avons besoin d'un dataset, entrez en un")
        
        let chatItem = ChatItem.create(context: managedObjectContext)
        chatItem.type = ChatItemType.actionButtonsUser
        chatItem.choices = [
            ChatItemChoice(name: "Import", action: {
                print("Import action")
                
                showDocumentPicker = true
                chatItem.type = ChatItemType.basicUser
                chatItem.content = "File sent"
                lesson.state = LessonSate.setup_finished
                try? managedObjectContext.save()
                Task { await botNextAction() }
            })
        ]
        lesson.addToChatItems(chatItem)
    }
    
    var body: some View {
        VStack {
            ChatItemListView(lesson: lesson)
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
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await botNextAction()
            }
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker(fileUrl: $fileUrl.onChange(fileUrlChanged))
        }
    }
    
    func fileUrlChanged(url: URL?) {
        guard let url = url else { return }
        print("We have some URL: \(url)")
        
        do {
            let path = try ImportBundle.unzipToTemp(zipfile: url)
            let lessonDTO = try ImportBundle.readJson(tempDirectory: path)
            try ImportBundle.saveLesson(lessonDTO: lessonDTO, lesson: lesson)
            print("Lesson importés: \(lessonDTO)")
        } catch FlashBotError.generalError(let message) {
            print("FlashBotError when reading Bundle: \(message)")
        } catch {
            print("Error when reading Bundle: \(error)")
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

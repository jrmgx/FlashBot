import SwiftUI
import zlib

struct LessonDetailView: View {

    @Environment(\.managedObjectContext) var managedObjectContext

    @StateObject var lesson: Lesson

    @State private var inputValue: String = ""
    @State private var botEventLoopActive = false

    // Setup
    @State private var lessonTitle = ""
    @State private var showDocumentPicker = false
    @State private var fileUrl: URL?

    // Session
    @State private var givenAnswer = ""
    @State private var numberOfWord = 0
    @State private var currentLessonEntry: LessonEntry?
    @State private var givenFeedback = false

    private func botEventLoop() async {
        guard botEventLoopActive else {
            return
        }

        // Resolve state
        let state = lesson.state

        // Execute action
        switch state {

        // Setup
        case .setupPresenting:
            await setupPresenting()
        case .setupWaitForLessonTitle:
            await setupWaitForLessonTitle()
        case .setupWaitForLessonEntries:
            await setupWaitForLessonEntries()
        case .setupFinished:
            lesson.state = LessonSate.sessionCanStart

        // Session
        case .sessionCanStart:
            await sessionCanStart()
        case .sessionNextQuestion:
            await sessionNextQuestion()
        case .sessionWaitForAnswer:
            await sessionWaitForAnswer()
        case .sessionRightAnswer:
            await sessionRightAnswer()
        case .sessionWrongAnswer:
            await sessionWrongAnswer()
        default:
            print("Unknown state for current lesson.")
            // Not much to do, so wait to prevent fast looping
            await Waits.seconds(seconds: 5)
        }

        // Loop
        await botEventLoop()
    }

    private func setupPresenting() async {

        await Waits.seconds(seconds: 0.5)

        lesson.appendBotMessage(text: "Hello!\nLet's configure your new lesson together.")
        await Waits.seconds(seconds: 1)

        lesson.appendBotMessage(text: "First of all, give your lesson a great title.")
        lesson.appendBotMessage(text: "Maybe you're learning Spanish, so it could be 'Learning Spanish'.")
        lesson.state = LessonSate.setupWaitForLessonTitle

        try? managedObjectContext.save()
    }

    private func setupWaitForLessonTitle() async {

        await Waits.untilTrue { !lessonTitle.isEmpty }

        lesson.title = lessonTitle
        lesson.appendBotMessage(text: "Great title!")
        lesson.state = LessonSate.setupWaitForLessonEntries

        try? managedObjectContext.save()
    }

    private func setupWaitForLessonEntries() async {

        await Waits.seconds(seconds: 0.5)

        lesson.appendBotMessage(text: "Now we need a dataset, find one and import it!")

        let chatItem = ChatItem.create(context: managedObjectContext)
        chatItem.type = ChatItemType.actionButtonsUser
        chatItem.choices = [
            ChatItemChoice(name: "Import") { _ in
                showDocumentPicker = true
                chatItem.type = ChatItemType.basicUser
                chatItem.content = "File sent"
            }
        ]
        lesson.addToChatItems(chatItem)

        // Don't save lesson now, it will be saved when the import is over
    }

    private func sessionCanStart() async {
        await Waits.seconds(seconds: 0.5)
        lesson.appendBotMessage(text: "It seems that you are ready for a new sessin")
        await Waits.seconds(seconds: 0.3)
        lesson.appendBotMessage(text: "Let's go!")
        lesson.state = LessonSate.sessionNextQuestion
        try? managedObjectContext.save()
    }

    /// Pick an entry and show it to the user
    private func sessionNextQuestion() async {
        await Waits.seconds(seconds: 0.5)

        guard let entry = LessonEntry.pickOne(entries: lesson.lessonEntries) else {
            lesson.state = LessonSate.unknown
            return
        }

        currentLessonEntry = entry

        lesson.appendBotMessage(text: entry.word)
        lesson.state = LessonSate.sessionWaitForAnswer
        try? managedObjectContext.save()
    }

    private func sessionWaitForAnswer() async {
        // TOOD stop les waits quand on presente plus
        await Waits.untilTrue { !givenAnswer.isEmpty }
        let currentAnswer = givenAnswer
        print(currentAnswer)
        givenAnswer = ""
        numberOfWord += 1

        // Check if good answer
        // TODO for now it's random
        await Waits.seconds(seconds: 0.5)

        if Date.now.hashValue % 2 == 0 {
            // Good
            lesson.state = LessonSate.sessionRightAnswer
        } else {
            // Wrong
            lesson.state = LessonSate.sessionWrongAnswer
        }
        try? managedObjectContext.save()
    }

    private func sessionRightAnswer() async {
        await Waits.seconds(seconds: 0.5)
        guard let entry = currentLessonEntry else {
            // TODO should send a message or make the session over?
            lesson.state = LessonSate.sessionNextQuestion
            return
        }

        lesson.appendBotMessage(text: "Great job, \"\(entry.translation)\" is the right anwser!")
        // lesson.state = LessonSate.sessionWaitForFeedback
        try? managedObjectContext.save()

        // Ask for feedback
        let chatItem = ChatItem.create(context: managedObjectContext)
        chatItem.type = ChatItemType.actionButtonsUser
        chatItem.choices = [
            ChatItemChoice(name: "Easy") { choice in
                print("Tap Easy")
                // TODO update score
                updateFeedbackCommon(chatItem: chatItem, choice: choice)
            },
            ChatItemChoice(name: "Medium") { choice in
                print("Tap Medium")
                updateFeedbackCommon(chatItem: chatItem, choice: choice)
            },
            ChatItemChoice(name: "Hard") { choice in
                print("Tap Hard")
                updateFeedbackCommon(chatItem: chatItem, choice: choice)
            },
            ChatItemChoice(name: "Skip") { choice in
                print("Tap Skip")
                updateFeedbackCommon(chatItem: chatItem, choice: choice)
            }
        ]
        lesson.addToChatItems(chatItem)
        await Waits.untilTrue { givenFeedback }
        givenFeedback = false
    }

    private func sessionWrongAnswer() async {
        await Waits.seconds(seconds: 0.5)
        guard let entry = currentLessonEntry else {
            // TODO should send a message or make the session over?
            lesson.state = LessonSate.sessionNextQuestion
            return
        }

        lesson.appendBotMessage(text: "Ho noes, \"\(entry.translation)\" was the right anwser!")

        updateStateIfSessionOver()
        try? managedObjectContext.save()
    }

    private func updateFeedbackCommon(chatItem: ChatItem, choice: ChatItemChoice) {
        givenFeedback = true
        chatItem.type = ChatItemType.basicUser
        chatItem.content = choice.name
        updateStateIfSessionOver()
        try? managedObjectContext.save()
    }

    private func updateStateIfSessionOver() {
        if numberOfWord < 10 {
            lesson.state = LessonSate.sessionNextQuestion
        } else {
            lesson.state = LessonSate.sessionOver
        }
    }

    var body: some View {
        VStack {
            ChatItemListView(lesson: lesson)
            HStack {
                ZStack {
                    TextField("Placeholder", text: $inputValue)
                    .onSubmit {
                        validate(text: inputValue)
                    }
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .border(.secondary)
                    .padding()
                    Button(
                        action: {

                        },
                        label: {
                            Text("I Don't\nKnow")
                            .multilineTextAlignment(.center)
                            .lineSpacing(-10)
                            .font(.system(size: 14))
                            .lineLimit(2)
                        }
                    )
                    .buttonStyle(PlainButtonStyle())
                    .padding()
                }
                Button("Send") {
                    print("Send")
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("Title").font(.headline)
                    Button("Subtitle") {
                        // ACTION
                    }
                }
            }
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker(fileUrl: $fileUrl.onChange(fileUrlChanged))
        }
        .onAppear {
            botEventLoopActive = true
            Task {
                await botEventLoop()
            }
        }
        .onDisappear {
            botEventLoopActive = false
        }
    }

    /// Handling text submited by the user
    /// It can use the lesson.state for specific actions
    /// - Parameter text: submited text
    private func validate(text: String) {
        if lesson.state == .setupWaitForLessonTitle {
            lessonTitle = text
        }

        if lesson.state == .sessionWaitForAnswer {
            givenAnswer = text
        }

        lesson.appendUserMessage(text: text)
        try? managedObjectContext.save()

        inputValue = ""
    }

    /// Handling file selected by the user in the import process
    /// - Parameter url: file path
    private func fileUrlChanged(url: URL?) {
        guard let url = url else { return }

        do {
            let path = try ImportBundle.unzipToTemp(zipfile: url)
            let lessonDTO = try ImportBundle.readJson(tempDirectory: path)
            try ImportBundle.saveLesson(lessonDTO: lessonDTO, lesson: lesson)
            print("Lesson importés: \(lessonDTO)")

            lesson.state = LessonSate.setupFinished
            try? managedObjectContext.save()

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

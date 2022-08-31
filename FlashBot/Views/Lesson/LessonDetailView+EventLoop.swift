import Foundation

extension LessonDetailView {

    func startEventLoop() async {
        if eventLoopActive {
            return
        }

        eventLoopActive = true

        // Resolve state
        let state = lesson.state
//        if sessionNewStart && lesson.state > LessonSate.sessionRestart {
//            state = LessonSate.sessionRestart
//        }
//        sessionNewStart = false

        // Execute action
        switch state {

        // Setup
        case .setupPresenting: await setupPresenting()
        case .setupAskForLessonTitle: await setupAskForLessonTitle()
        case .setupWaitForLessonTitle: stopEventLoop()
        case .setupAskForLessonEntries: await setupAskForLessonEntries()
        case .setupWaitForLessonEntries: stopEventLoop()

        // Session
        case .sessionRestart: await sessionRestart()
        case .sessionCanStart: await sessionCanStart()
        case .sessionNextQuestion: await sessionNextQuestion()
        case .sessionWaitForAnswer: stopEventLoop()
        case .sessionRightAnswer: await sessionRightAnswer()
        case .sessionWaitForFeedback: stopEventLoop()
        case .sessionWrongAnswer: await sessionWrongAnswer()
        case .sessionOver: await sessionOver()
        default:
            print("Unknown state for current lesson.")
            // Not much to do, so wait to prevent fast looping
            await Waits.seconds(seconds: 5)
        }

        // Loop
        if !eventLoopActive {
            return
        }
        eventLoopActive = false
        await startEventLoop()
    }

    func stopEventLoop() {
        eventLoopActive = false
    }

    private func setupPresenting() async {

        await Waits.seconds(seconds: 0.5)
        lesson.appendBotMessage(text: "Hello!\nLet's configure your new lesson together.")

        lesson.state = LessonSate.setupAskForLessonTitle

        try? managedObjectContext.save()
    }

    private func setupAskForLessonTitle() async {

        await Waits.seconds(seconds: 1)
        lesson.appendBotMessage(text: "First of all, give your lesson a great title.")
        lesson.appendBotMessage(text: "Maybe you're learning Spanish, so it could be 'Learning Spanish'.")

        lesson.state = LessonSate.setupWaitForLessonTitle

        try? managedObjectContext.save()

        stopEventLoop()
    }

    func startEventLoop(withLessonTitle title: String) async {

        lesson.title = title
        lesson.appendBotMessage(text: "Great title!")
        lesson.state = LessonSate.setupAskForLessonEntries

        try? managedObjectContext.save()

        await startEventLoop()
    }

    private func setupAskForLessonEntries() async {

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

        lesson.state = LessonSate.setupWaitForLessonEntries

        // Don't save lesson now, it will be saved when the import is over
        // try? managedObjectContext.save()

        stopEventLoop()
    }

    func startEventLoop(withLessonEntries lessonDTO: LessonDTO) async throws {

        try ImportBundle.saveLesson(lessonDTO: lessonDTO, lesson: lesson)
        print("Lesson importés: \(lessonDTO)")
        await Waits.seconds(seconds: 0.5)
        lesson.appendBotMessage(text: "Got it!")

        lesson.state = LessonSate.sessionCanStart

        try? managedObjectContext.save()

        await startEventLoop()
    }

    private func sessionCanStart() async {
        await Waits.seconds(seconds: 0.5)
        lesson.appendBotMessage(text: "It seems that you are ready for a new session")
        await Waits.seconds(seconds: 0.3)
        lesson.appendBotMessage(text: "Let's go!")

        lesson.state = LessonSate.sessionNextQuestion

        try? managedObjectContext.save()
    }

    private func sessionRestart() async {
        await Waits.seconds(seconds: 0.5)
        lesson.appendBotMessage(text: "It's been a while, let's start a new session!")

        lesson.state = LessonSate.sessionNextQuestion

        try? managedObjectContext.save()
    }

    /// Pick an entry and show it to the user
    private func sessionNextQuestion() async {
        guard let entry = LessonEntry.pickOne(entries: lesson.lessonEntries) else {
            lesson.state = LessonSate.exceptionalNoMoreEntries
            // TODO améliorer avec l'affichage d'un message d'erreur dans le chat
            stopEventLoop()
            return
        }

        currentLessonEntry = entry

        await Waits.seconds(seconds: 0.5)
        lesson.appendBotMessage(text: entry.word)

        lesson.state = LessonSate.sessionWaitForAnswer

        try? managedObjectContext.save()

        stopEventLoop()
    }

    func startEventLoop(withAnswer answer: String) async {

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

        await startEventLoop()
    }

    private func sessionRightAnswer() async {
        await Waits.seconds(seconds: 0.5)

        lesson.appendBotMessage(text: "Great job, \"\(currentLessonEntry.translation)\" is the right anwser!")

        lesson.state = LessonSate.sessionWaitForFeedback

        try? managedObjectContext.save()

        // Ask for feedback
        let chatItem = ChatItem.create(context: managedObjectContext)
        chatItem.type = ChatItemType.actionButtonsUser
        chatItem.choices = [
            ChatItemChoice(name: "Easy") { choice in
                updateFeedbackCommon(
                    chatItem: chatItem, choice: choice, score: LessonEntry.scoreEasy
                )
            },
            ChatItemChoice(name: "Medium") { choice in
                updateFeedbackCommon(
                    chatItem: chatItem, choice: choice, score: LessonEntry.scoreMedium
                )
            },
            ChatItemChoice(name: "Hard") { choice in
                updateFeedbackCommon(
                    chatItem: chatItem, choice: choice, score: LessonEntry.scoreHard
                )
            },
            ChatItemChoice(name: "Skip") { choice in
                updateFeedbackCommon(
                    chatItem: chatItem, choice: choice, score: LessonEntry.scoreSkip
                )
            }
        ]
        lesson.addToChatItems(chatItem)

        try? managedObjectContext.save()

        stopEventLoop()
    }

    private func updateFeedbackCommon(chatItem: ChatItem, choice: ChatItemChoice, score: Int) {
        if let currentLessonEntry = currentLessonEntry {
            currentLessonEntry.score += Int16(score)
        }
        chatItem.type = ChatItemType.basicUser
        chatItem.content = choice.name

        lessonUpdateStateIfSessionOver()

        try? managedObjectContext.save()

        Task { await startEventLoop() }
    }

    private func sessionWrongAnswer() async {
        await Waits.seconds(seconds: 0.5)

        lesson.appendBotMessage(text: "Ho noes, \"\(currentLessonEntry.translation)\" was the right anwser!")

        lessonUpdateStateIfSessionOver()

        try? managedObjectContext.save()
    }

    func startEventLoop(withIDontKnow idk: Bool) async {
        guard lesson.state == LessonSate.sessionWaitForAnswer else {
            return
        }

        lesson.appendUserMessage(text: "I don't know")
        await Waits.seconds(seconds: 0.5)

        lesson.appendBotMessage(text: "No problem, it was \"\(currentLessonEntry.translation)\"")

        lessonUpdateStateIfSessionOver()
        try? managedObjectContext.save()

        await startEventLoop()
    }

    private func lessonUpdateStateIfSessionOver() {
        if numberOfWord < 10 {
            lesson.state = LessonSate.sessionNextQuestion
        } else {
            lesson.state = LessonSate.sessionOver
        }
    }

    private func sessionOver() async {
        await Waits.seconds(seconds: 0.5)
        lesson.appendBotMessage(text: "Great, your session is over!")

        await Waits.seconds(seconds: 10)

        lesson.state = LessonSate.sessionNextQuestion

        try? managedObjectContext.save()
    }
}

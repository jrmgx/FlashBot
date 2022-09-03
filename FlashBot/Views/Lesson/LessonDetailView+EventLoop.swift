import Foundation

extension LessonDetailView {

    func startEventLoop() async {
        if eventLoopActive {
            return
        }

        eventLoopActive = true

        // Resolve state
        var state = lesson.state
        if sessionNewStart && lesson.state > LessonSate.sessionRestart {
            state = LessonSate.sessionRestart
            lesson.state = LessonSate.sessionRestart
        }
        sessionNewStart = false

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

        // Add word
        case .addWordWaitForWord: stopEventLoop()

        default:
            print("Unknown state for current lesson.")
            // Not much to do, so wait to prevent fast looping
            lesson.appendBotMessage(text: "Unknown state for current lesson.")
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
                chatItem.content = "Picker Open"
            }
        ]
        lesson.addToChatItems(chatItem)

        lesson.state = LessonSate.setupWaitForLessonEntries

        // Don't save lesson now, it will be saved when the import is over
        // try? managedObjectContext.save()

        stopEventLoop()
    }

    func startEventLoop(withLessonEntries lessonDTO: LessonDTO) async throws {

        lesson.appendUserMessage(text: "File Sent")
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

        let chatItem = ChatItem.create(context: managedObjectContext)
        chatItem.type = ChatItemType.actionButtonsUser
        chatItem.choices = [
            ChatItemChoice(name: "Start a new session!") { _ in
                chatItem.content = "Start a new session!"
                Task { await startEventLoop(withNewSession: true) }
            }
        ]
        lesson.addToChatItems(chatItem)

        stopEventLoop()
        // lesson.state = LessonSate.sessionNextQuestion

        // try? managedObjectContext.save()
    }

    func startEventLoop(withNewSession: Bool) async {
        await Waits.seconds(seconds: 0.3)
        lesson.appendBotMessage(text: "Let's go!")
        lesson.state = LessonSate.sessionNextQuestion

        try? managedObjectContext.save()

        await startEventLoop()
    }

    private func sessionRestart() async {
        await sessionCanStart()
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
        let normalizedAnswer = answer.normalize()
        let normalizedEntry = currentLessonEntry.translation.normalize()

        if
            let normalizedEntry = normalizedEntry,
            let normalizedAnswer = normalizedAnswer,
            normalizedAnswer.elementsEqual(normalizedEntry)
        {
            // Good
            lesson.state = LessonSate.sessionRightAnswer
        } else {
            // Wrong
            lesson.state = LessonSate.sessionWrongAnswer
        }

        await Waits.seconds(seconds: 0.5)

        try? managedObjectContext.save()

        await startEventLoop()
    }

    private func sessionRightAnswer() async {
        await Waits.seconds(seconds: 0.5)

        lesson.appendBotMessage(text: "✅ Great job,\n\"\(currentLessonEntry.translation)\" is the right anwser!")

        lesson.state = LessonSate.sessionWaitForFeedback

        try? managedObjectContext.save()

        // Ask for feedback
        let chatItem = ChatItem.create(context: managedObjectContext)
        chatItem.type = ChatItemType.actionButtonsUser
        chatItem.choices = [
            ChatItemChoice(name: "👍") { choice in
                updateFeedbackCommon(
                    chatItem: chatItem, choice: choice, score: LessonEntry.scoreEasy
                )
            },
            ChatItemChoice(name: "⛅️") { choice in
                updateFeedbackCommon(
                    chatItem: chatItem, choice: choice, score: LessonEntry.scoreMedium
                )
            },
            ChatItemChoice(name: "👎") { choice in
                updateFeedbackCommon(
                    chatItem: chatItem, choice: choice, score: LessonEntry.scoreHard
                )
            },
            ChatItemChoice(name: "🗑") { choice in
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

        lesson.appendBotMessage(text: "❌ Ho noes,\n\"\(currentLessonEntry.translation)\" was the right anwser!")

        lessonUpdateStateIfSessionOver()

        try? managedObjectContext.save()
    }

    func startEventLoop(withIDontKnow idk: Bool) async {
        guard lesson.state == LessonSate.sessionWaitForAnswer else {
            return
        }

        numberOfWord += 1

        lesson.appendUserMessage(text: "I don't know")
        await Waits.seconds(seconds: 0.5)

        lesson.appendBotMessage(text: "➡️ No problem,\nit was \"\(currentLessonEntry.translation)\"")

        lessonUpdateStateIfSessionOver()
        try? managedObjectContext.save()

        await startEventLoop()
    }

    func addWord() async {

        stopEventLoop()
        lesson.state = LessonSate.addWordWaitForWord

        lesson.appendBotMessage(text: "To add a word: enter it, then an equal sign, and then its signification")
        lesson.appendBotMessage(text: "Like this:\nEnfants = Children")

        try? managedObjectContext.save()

    }

    func startEventLoop(withNewWord word: String) async {

        let sub = word.split(separator: "=")
        guard sub.count == 2, let first = sub.first, let second = sub.last else {
            lesson.appendBotMessage(text: "Oops the format does not seem right")
            await addWord()
            return
        }

        // TODO check if the word already exist in the lesson
        
        let word = first
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        let translation = second
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        lesson.appendLessonEntry(word: word, translation: translation)
        await Waits.seconds(seconds: 0.5)
        lesson.appendBotMessage(
            text: "Great I added \"\(word)\" meaning \"\(translation)\""
        )

        numberOfWord = 0

        lesson.state = LessonSate.sessionCanStart

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

        numberOfWord = 0

        lesson.state = LessonSate.sessionCanStart

        try? managedObjectContext.save()
    }
}

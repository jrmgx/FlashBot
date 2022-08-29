import Foundation

extension LessonDetailView {

    func botEventLoop() async {
        guard botEventLoopActive else {
            return
        }

        // Resolve state
        var state = lesson.state
        if sessionNewStart && lesson.state > LessonSate.sessionRestart {
            state = LessonSate.sessionRestart
        }

        // Execute action
        switch state {

        // Setup
        case .setupPresenting:
            await setupPresenting()
        case .setupWaitForLessonTitle:
            await setupWaitForLessonTitle()
        case .setupWaitForLessonEntries:
            await setupWaitForLessonEntries()
        case .setupFinished: // TODO remove
            lesson.state = LessonSate.sessionCanStart

        // Session
        case .sessionRestart:
            await sessionRestart()
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

        // textFieldFocused = true

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

    private func sessionRestart() async {
        await Waits.seconds(seconds: 0.5)
        lesson.appendBotMessage(text: "It's been a while, let's start a new session!")
        lesson.state = LessonSate.sessionNextQuestion
        try? managedObjectContext.save()
    }

    /// Pick an entry and show it to the user
    private func sessionNextQuestion() async {
        await Waits.seconds(seconds: 0.5)

        guard let entry = LessonEntry.pickOne(entries: lesson.lessonEntries) else {
            lesson.state = LessonSate.exceptionalNoMoreEntries
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

        lesson.appendBotMessage(text: "Great job, \"\(currentLessonEntry.translation)\" is the right anwser!")
        // lesson.state = LessonSate.sessionWaitForFeedback
        try? managedObjectContext.save()

        // Ask for feedback
        let chatItem = ChatItem.create(context: managedObjectContext)
        chatItem.type = ChatItemType.actionButtonsUser
        chatItem.choices = [
            ChatItemChoice(name: "Easy") { choice in
                // TODO update score
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
        await Waits.untilTrue { givenFeedback }
        givenFeedback = false
    }

    private func sessionWrongAnswer() async {
        await Waits.seconds(seconds: 0.5)

        lesson.appendBotMessage(text: "Ho noes, \"\(currentLessonEntry.translation)\" was the right anwser!")

        updateStateIfSessionOver()
        try? managedObjectContext.save()
    }

    func sessionIDontKnow() async {
        lesson.appendUserMessage(text: "I don't know")
        await Waits.seconds(seconds: 0.5)

        lesson.appendBotMessage(text: "No problem, it was \"\(currentLessonEntry.translation)\"")

        updateStateIfSessionOver()
        try? managedObjectContext.save()

        await botEventLoop()
    }

    private func updateFeedbackCommon(chatItem: ChatItem, choice: ChatItemChoice, score: Int) {
        if let currentLessonEntry = currentLessonEntry {
            currentLessonEntry.score += Int16(score)
        }
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

}

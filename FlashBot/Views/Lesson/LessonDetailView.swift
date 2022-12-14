import SwiftUI
import zlib
import UniformTypeIdentifiers.UTType
import Foundation

struct LessonDetailView: View {

    @Environment(\.managedObjectContext) var managedObjectContext

    @StateObject var lesson: Lesson

    @State private var inputValue: String = ""
    @FocusState var textFieldFocused: Bool
    @State var textFieldEnabled = true
    @State var eventLoopActive = false
    @State private var showSettings = false

    // Setup
    @State var lessonTitle = ""
    @State var showPicker = false
    @State private var fileUrl: URL?

    // Session
    @State var sessionNewStart = true
    @State var givenAnswer = ""
    @State var numberOfWord = 0
    @State var currentLessonEntry: LessonEntry!
    @State var givenFeedback = true

    var body: some View {
        VStack {
            if FlashBotApp.isDebug {
                Text("\(String(describing: lesson.state)) \(numberOfWord)")
            }
            ChatItemListView(lesson: lesson)
            .background(Color("ChatBackground"))
            HStack {
                ZStack {
                    TextField("Text", text: $inputValue)
                    // .disabled(!textFieldEnabled || !givenFeedback)
                    .onSubmit {
                        validate(text: inputValue)
                        textFieldFocused = true
                    }
                    .focused($textFieldFocused)
                    .keyboardType(.alphabet)
                    .disableAutocorrection(true)
                    .lineLimit(nil)
                    .padding(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 100)
                        .strokeBorder(Color.black, style: StrokeStyle(lineWidth: 1.0))
                    )
                    .padding()
                    if lesson.state == LessonSate.sessionWaitForAnswer {
                        HStack {
                            Spacer()
                            Button(
                                action: {
                                    Task { await startEventLoop(withIDontKnow: true) }
                                    inputValue = ""
                                    textFieldFocused = true
                                },
                                label: {
                                    Text("I Don't\nKnow")
                                    .padding()
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(0)
                                    .font(.system(size: 13))
                                    .lineLimit(2)
                                }
                            )
                            .buttonStyle(PlainButtonStyle())
                            .padding()
                        }
                    }
                }
            }
            .padding(.vertical, -12)
        }
        .navigationTitle(lesson.title)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                LessonDetailToolbarButtonPrimary(
                    actionAdd: menuActionAddWord,
                    actionTranslate: menuActionTranslate,
                    actionSettings: menuActionSettings
                )
            }
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color("Background"), for: .navigationBar)
        .fileImporter(isPresented: $showPicker, allowedContentTypes: [UTType("net.gangneux.flashbotLesson")!]) { result in
            switch result {
            case .success(let url):
                fileUrl(url: url)
            case.failure:
                print("File failed to load")
            }
        }
        .sheet(isPresented: $showSettings) {
            LessonSettingView()
        }
        .onAppear {
            Task {
                await startEventLoop()
            }
        }
        .onDisappear {
            stopEventLoop()
        }
    }

    private func menuActionAddWord() {
        Task { await addWord() }
    }

    private func menuActionTranslate() {
        Task { await translateWord() }
    }

    private func menuActionSettings() {
        showSettings = true
    }

    /// Handling text submited by the user
    /// It can use the lesson.state for specific actions
    /// - Parameter text: submited text
    private func validate(text: String) {

        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard text.lengthOfBytes(using: .utf8) > 0 else {
            inputValue = ""
            return
        }

        
        lesson.appendUserMessage(text: text)
        try? managedObjectContext.save()

        inputValue = ""
        textFieldFocused = true
        /// TODO keep the keyboard open
        
        /// Handle specific text like adding an entry, asking for a translation...
        Task {
            if await applyCommand(text: text) {
                // Noop
            }
            else if lesson.state == .setupWaitForLessonTitle {
                await startEventLoop(withLessonTitle: text)
            }
            else if lesson.state == .sessionWaitForAnswer {
                await startEventLoop(withAnswer: text)
            }
            else if lesson.state == .addWordWaitForWord {
                await startEventLoop(withNewWord: text)
            }
            else if lesson.state == .askTranslationWaitForWord {
                await translateLang(word: text)
            }
        }

    }

    /// Handling file selected by the user in the import process
    /// - Parameter url: file path
    private func fileUrl(url: URL?) {
        guard let url = url else { return }

        do {
            let path = try ImportBundle.unzipToTemp(zipfile: url)
            let lessonDTO = try ImportBundle.readJson(tempDirectory: path)
            Task { try await startEventLoop(withLessonEntries: lessonDTO) }

        } catch FlashBotError.generalError(let message) {
            print("Error when reading Bundle: \(message)")
        } catch {
            print("Error when reading Bundle: \(error)")
        }
    }
}

struct LessonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LessonDetailView(lesson: PersistenceController.preview.fakeLessons[0])
            .environment(
                \.managedObjectContext,
                PersistenceController.preview.container.viewContext
            )
        }
    }
}

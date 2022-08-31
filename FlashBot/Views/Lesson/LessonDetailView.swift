import SwiftUI
import zlib

struct LessonDetailView: View {

    @Environment(\.managedObjectContext) var managedObjectContext

    @StateObject var lesson: Lesson

    @State private var inputValue: String = ""
    @FocusState var textFieldFocused: Bool
    @State var textFieldEnabled = true
    @State var eventLoopActive = false

    // Setup
    @State var lessonTitle = ""
    @State var showDocumentPicker = false
    @State private var fileUrl: URL?

    // Session
    @State var sessionNewStart = true
    @State var givenAnswer = ""
    @State var numberOfWord = 0
    @State var currentLessonEntry: LessonEntry!
    @State var givenFeedback = true

    private let isDebug = true

    var body: some View {
        VStack {
            if isDebug {
                Text("\(String(describing: lesson.state)) \(numberOfWord)")
            }
            ChatItemListView(lesson: lesson)
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                LessonDetailHeaderView(
                    title: lesson.title,
                    actionAdd: menuActionAddWord,
                    actionTranslate: menuActionTranslate,
                    actionSettings: menuActionSettings
                )
            }
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker(fileUrl: $fileUrl.onChange(fileUrlChanged))
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
        print("Tap on add word")
    }

    private func menuActionTranslate() {
        print("Tap on translate")
    }

    private func menuActionSettings() {
        print("Tap on settings")
    }

    /// Handling text submited by the user
    /// It can use the lesson.state for specific actions
    /// - Parameter text: submited text
    private func validate(text: String) {
        if lesson.state == .setupWaitForLessonTitle {
            Task { await startEventLoop(withLessonTitle: text) }
        }

        if lesson.state == .sessionWaitForAnswer {
            Task { await startEventLoop(withAnswer: text) }
        }

        lesson.appendUserMessage(text: text)
        try? managedObjectContext.save()

        inputValue = ""
        textFieldFocused = true
        /// TODO keep the keyboard open
    }

    /// Handling file selected by the user in the import process
    /// - Parameter url: file path
    private func fileUrlChanged(url: URL?) {
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

import SwiftUI
import Combine

struct ChatItemListView: View, KeyboardReadable {
    
    @StateObject var lesson: Lesson

    /// @TODO how not to load the full chat items?
//    @FetchRequest(sortDescriptors: [
//        SortDescriptor(\.postedAt, order: .reverse)
//    ]) var chatItems: FetchedResults<ChatItem>

    @State private var isKeyboardVisible = false
    
    private func scrollBottom(scrollViewProxy: ScrollViewProxy, animate: Bool) {
        guard !lesson.chatItems.isEmpty else { return }
        Task {
            if animate {
                withAnimation(Animation.easeInOut) {
                    scrollViewProxy.scrollTo(lesson.chatItems.last!.id, anchor: .top)
                }
            } else {
                scrollViewProxy.scrollTo(lesson.chatItems.last!.id, anchor: .top)
            }
        }
    }
    
    var body: some View {
        
        ScrollViewReader { scrollViewProxy in
            List(lesson.chatItems) { chatItem in
                ChatItemRowView(chatItem: chatItem).id(chatItem.id)
            }
            .onAppear {
                scrollBottom(scrollViewProxy: scrollViewProxy, animate: false)
            }
            .onReceive(lesson.objectWillChange) { _ in
                scrollBottom(scrollViewProxy: scrollViewProxy, animate: true)
            }
            .onReceive(keyboardPublisher) { _ in
                scrollBottom(scrollViewProxy: scrollViewProxy, animate: true)
            }
        }
    }
}

struct ChatItemListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ChatItemListView(lesson: PersistenceController.preview.fakeLessons[0])
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            ChatItemListView(lesson: Lesson())
        }
    }
}

/// Publisher to read keyboard changes.
/// https://stackoverflow.com/a/65784549/696517
protocol KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> { get }
}

extension KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardDidShowNotification)
                .map { _ in true },
            
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardDidHideNotification)
                .map { _ in false }
        )
        .eraseToAnyPublisher()
    }
}


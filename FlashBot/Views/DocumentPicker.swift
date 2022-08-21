import SwiftUI
import Foundation

struct DocumentPicker: UIViewControllerRepresentable {

    typealias UIViewControllerType = UIDocumentPickerViewController
    
    @Binding var fileContent: String
    
    func makeCoordinator() -> DocumentPickerCoordinator {
        return DocumentPickerCoordinator(fileContent: $fileContent)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.data], asCopy: true)
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        
    }
}

class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate {
    
    @Binding var fileContent: String
    
    init(fileContent: Binding<String>) {
        _fileContent = fileContent
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        //
        print(urls)
        let fileURL = urls[0]
        do {
            fileContent = try String(contentsOf: fileURL, encoding: .utf8)
            print(fileContent)
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

import SwiftUI
import Foundation

struct DocumentPicker: UIViewControllerRepresentable {

    typealias UIViewControllerType = UIDocumentPickerViewController
    
    @Binding var fileUrl: URL?
    
    func makeCoordinator() -> DocumentPickerCoordinator {
        return DocumentPickerCoordinator(fileUrl: $fileUrl)
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
    
    @Binding var fileUrl: URL?
    
    init(fileUrl: Binding<URL?>) {
        _fileUrl = fileUrl
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        //
        print(urls)
        //guard let urlFirst = urls.first else { return }
        fileUrl = urls.first
        //fileUrl = urls.first
        //let fileURL = urls[0]
        //do {
        //    fileContent = try String(contentsOf: fileURL, encoding: .utf8)
        //    print(fileContent)
        //} catch let error {
        //    print(error.localizedDescription)
        //}
    }
}

import Foundation

struct Deepl {

    static func translate(text: String, sourceLang: String, targetLang: String) async throws -> DeeplResponse {
    
        let boundary = "BOUNDARY-\(NSUUID().uuidString)"
        let body =
            textFormField(named: "text", value: text, boundary: boundary) +
            textFormField(named: "source_lang", value: sourceLang, boundary: boundary) +
            textFormField(named: "target_lang", value: targetLang, boundary: boundary) +
            "--\(boundary)--"

        let url = URL(string: "https://api-free.deepl.com/v2/translate")

        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("DeepL-Auth-Key a526d9f0-643f-4f13-40e8-4f83545e409a:fx", forHTTPHeaderField: "Authorization")
        request.httpBody = body.data(using: .utf8)

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(DeeplResponse.self, from: data)
    }

    static private func textFormField(named name: String, value: String, boundary: String) -> String {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"

        return fieldString
    }

}

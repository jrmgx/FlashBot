import Foundation

struct Deepl {

    func translate(word: String, lang: String, completion: @escaping (DeeplResponse?, FlashBotError?) -> Void) {

        let boundary = "BOUNDARY-\(NSUUID().uuidString)"
        let body =
            textFormField(named: "text", value: word, boundary: boundary) +
            textFormField(named: "target_lang", value: lang, boundary: boundary) +
            "--\(boundary)--"

        let url = URL(string: "https://api-free.deepl.com/v2/translate")

        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("DeepL-Auth-Key a526d9f0-643f-4f13-40e8-4f83545e409a:fx", forHTTPHeaderField: "Authorization")
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, _, error in

            guard let data = data, error == nil else {
                completion(nil, FlashBotError.translationError(
                    message: "Error while requesting translation for \(word)")
                )
                return
            }

            let result = try? JSONDecoder().decode(DeeplResponse.self, from: data)
            if let result = result {
                completion(result, nil)
            } else {
                completion(nil, FlashBotError.translationError(message: "Error while decoding translation for \(word)"))
            }
        }.resume()
    }

    private func textFormField(named name: String, value: String, boundary: String) -> String {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"

        return fieldString
    }

}

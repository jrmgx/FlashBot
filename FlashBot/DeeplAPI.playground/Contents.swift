import Foundation

/* {
    "translations": [
        {
            "detected_source_language": "EN",
            "text": "Bonjour le monde"
        }
    ]
} */

struct DeeplApiTranslation: Codable {
    let detected_source_language: String
    let text: String
}
struct DeeplApiResponse: Codable {
    let translations: [DeeplApiTranslation]
}
func textFormField(named name: String, value: String, boundary: String) -> String {
    var fieldString = "--\(boundary)\r\n"
    fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
    fieldString += "\r\n"
    fieldString += "\(value)\r\n"

    return fieldString
}
let text = "case"
let target_lang = "FR"

let boundary = "BOUNDARY-\(NSUUID().uuidString)"
var body = textFormField(named: "text", value: text, boundary: boundary)
body += textFormField(named: "target_lang", value: target_lang, boundary: boundary)
body += "--\(boundary)--"

let url = URL(string: "https://api-free.deepl.com/v2/translate")
var request = URLRequest(url: url!)

request.httpMethod = "POST"
request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
request.setValue("DeepL-Auth-Key a526d9f0-643f-4f13-40e8-4f83545e409a:fx", forHTTPHeaderField: "Authorization")
request.httpBody = body.data(using: .utf8)

URLSession.shared.dataTask(with: request) { (data, _, error) in

    guard let data = data, error == nil else {
        print("domain error 01")
        return
    }
    let result = try? JSONDecoder().decode(DeeplApiResponse.self, from: data)
    if let result = result {
        DispatchQueue.main.async {
            print(result)
        }
    } else {
        DispatchQueue.main.async {
            print("domain error 02")
        }
    }
}.resume()

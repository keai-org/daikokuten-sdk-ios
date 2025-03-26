import Foundation

public class Daikokuten {
    // Static method to send context data via POST using URLSession
    public static func context(userId: String, eventId: String, action: String) {
        guard let url = URL(string: "https://daikokuten-7c6ffc95ca37.herokuapp.com/context") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "user_id": userId,
            "event_id": eventId,
            "action": action
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("Daikokuten: Failed to serialize context data: \(error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Daikokuten: POST request failed: \(error)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                print("Daikokuten: Context data sent successfully")
            } else {
                print("Daikokuten: Unexpected response: \(String(describing: response))")
            }
        }
        task.resume()
    }
}
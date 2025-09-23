import Foundation

class WebSocketManager: ObservableObject {
    @Published var messages: [Message] = []
    private var webSocket: URLSessionWebSocketTask?
    private let urlString = "ws://ec2-3-39-9-151.ap-northeast-2.compute.amazonaws.com:3000/ws/chat"

    init() {
        connect()
    }

    func connect() {
        guard let url = URL(string: urlString) else { return }
        let session = URLSession(configuration: .default)
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()
        listen()
    }

    func send(text: String) {
        let messageData: [String: Any] = ["message": text]
        if let json = try? JSONSerialization.data(withJSONObject: messageData),
           let jsonString = String(data: json, encoding: .utf8) {
            webSocket?.send(.string(jsonString)) { error in
                if let error = error {
                    print("WebSocket 전송 오류: \(error)")
                }
            }
        }
        DispatchQueue.main.async {
            self.messages.append(Message(text: text, isUser: true))
        }
    }

    private func listen() {
        webSocket?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    if let data = text.data(using: .utf8),
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let reply = json["message"] as? String {
                        DispatchQueue.main.async {
                            self?.messages.append(Message(text: reply, isUser: false))
                        }
                    }
                default:
                    break
                }
                self?.listen() // 계속 수신 대기
            case .failure(let error):
                print("WebSocket 수신 오류: \(error)")
            }
        }
    }

    func disconnect() {
        webSocket?.cancel(with: .goingAway, reason: nil)
    }
}

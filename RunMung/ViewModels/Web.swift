//
//  Untitled.swift
//  RunMung
//
//  Created by 고래돌 on 9/23/25.
//

import Foundation

class WebSocketManager: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    @Published var messages: [Message] = []
    
    init() {
        connect()
    }
    
    func connect() {
        guard let url = URL(string: "ws://localhost:8000/chat") else { return }
        let request = URLRequest(url: url)
        webSocketTask = URLSession.shared.webSocketTask(with: request)
        webSocketTask?.resume()
        listen()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    func send(_ text: String) {
        let json: [String: String] = ["message": text]
        if let data = try? JSONSerialization.data(withJSONObject: json),
           let jsonString = String(data: data, encoding: .utf8) {
            
            let message = URLSessionWebSocketTask.Message.string(jsonString)
            webSocketTask?.send(message) { error in
                if let error = error {
                    print("Send error: \(error)")
                }
            }
            
            // 로컬에도 내가 보낸 메시지 추가
            DispatchQueue.main.async {
                self.messages.append(Message(text: text, isUser: true))
            }
        }
    }
    
    private func listen() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("Receive error: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    if let data = text.data(using: .utf8),
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let msg = json["message"] as? String {
                        DispatchQueue.main.async {
                            self?.messages.append(Message(text: msg, isUser: false))
                        }
                    }
                default:
                    break
                }
            }
            // 계속 대기
            self?.listen()
        }
    }
}

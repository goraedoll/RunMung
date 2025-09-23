//
//  DogChatView.swift
//  RunMung
//
//  Created by 고래돌 on 9/23/25.
//
import SwiftUI

// 키보드 내리기 유틸리티
extension UIApplication {
    func endEditing(_ force: Bool) {
        self.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct DogChatView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var messages: [Message] = [
        Message(text: "멍! 오늘 산책 가고 싶어 🐾", isUser: false),
        Message(text: "좋아! 몇 시에 나갈까?", isUser: true),
        Message(text: "지금 바로!! 🐶✨", isUser: false)
    ]
    
    @State private var inputText: String = ""

    var body: some View {
        VStack {
            // 상단 헤더 (아이콘 추가)
            HStack {
                Button(action: {
                    goToMainTabView()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .semibold))
                }
                
                Spacer()
                
                Text("✨AI로 질문하기")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    print("옵션 버튼 눌림")
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            .padding()
            .background(Color.coral)
            
            // 대화 영역 (자동 스크롤)
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(messages) { msg in
                            ChatBubble(message: msg)
                                .id(msg.id) // 각 메시지에 id 부여
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { oldValue, newValue in
                    if newValue > oldValue, let lastID = messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastID, anchor: . bottom)
                        }
                    }
                }
                .onTapGesture {
                    UIApplication.shared.endEditing(true)
                }
            }
            
            // 입력창
            HStack {
                TextField("메시지를 입력하세요...", text: $inputText)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .font(.system(size: 16, weight: .regular))
                
                Button(action: {
                    if !inputText.isEmpty {
                        messages.append(Message(text: inputText, isUser: true))
                        inputText = ""
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.coral)
                        .clipShape(Circle())
                        .shadow(radius: 1)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

func goToMainTabView() {
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let window = windowScene.windows.first {
        window.rootViewController = UIHostingController(
            rootView: MainTabView()
                .environmentObject(TimerManager())
                .environmentObject(DistanceTracker())
                .environmentObject(PhotoManager())
                .environmentObject(PhotoDisplayManager())
        )
        window.makeKeyAndVisible()
    }
}


// 메시지 모델
struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

// 말풍선 뷰
struct ChatBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                Text(message.text)
                    .font(.system(size: 16, weight: .regular))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.coral)
                    .foregroundColor(.white)
                    .cornerRadius(22)
                    .frame(maxWidth: 280, alignment: .trailing)
            } else {
                Text(message.text)
                    .font(.system(size: 16, weight: .regular))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray5).opacity(0.9))
                    .foregroundColor(.black)
                    .cornerRadius(22)
                    .frame(maxWidth: 280, alignment: .leading)
                Spacer()
            }
        }
    }
}

// 미리보기
struct DogChatView_Previews: PreviewProvider {
    static var previews: some View {
        DogChatView()
    }
}

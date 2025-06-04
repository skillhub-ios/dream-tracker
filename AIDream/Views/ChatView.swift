import SwiftUI
// import AIDream.Models.Message

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            // Заголовок
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                }
                
                Text("Чат с AI")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { viewModel.clearChat() }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            .padding()
            
            // Сообщения
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message)
                    }
                }
                .padding()
            }
            
            // Индикатор загрузки
            if viewModel.isProcessing {
                ProgressView()
                    .padding()
            }
            
            // Поле ввода
            HStack {
                TextField("Введите сообщение...", text: $viewModel.inputMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(viewModel.isProcessing)
                
                Button(action: {
                    Task {
                        await viewModel.sendMessage()
                    }
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.dreamPrimary)
                }
                .disabled(viewModel.inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isProcessing)
            }
            .padding()
        }
        .alert("Ошибка", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") {
                viewModel.error = nil
            }
        } message: {
            Text(viewModel.error?.localizedDescription ?? "Произошла неизвестная ошибка")
        }
    }
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.role == Role.assistant {
                Spacer()
            }
            
            Text(message.content)
                .padding()
                .background(message.role == Role.user ? Color.dreamPrimary.opacity(0.2) : Color.gray.opacity(0.2))
                .cornerRadius(12)
            
            if message.role == Role.user {
                Spacer()
            }
        }
    }
}

#Preview {
    ChatView()
} 
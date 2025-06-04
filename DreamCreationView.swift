import SwiftUI

struct DreamCreationView: View {
    @State private var isInterpreted = false
    @State private var interpretation: DreamInterpretation?
    @StateObject private var viewModel = DreamCreationViewModel()

    var body: some View {
        ZStack {
            if isInterpreted, let interpretation = interpretation {
                DreamInterpretationScreen(
                    interpretation: interpretation,
                    onDone: {
                        withAnimation { isInterpreted = false }
                    },
                    viewModel: viewModel
                )
                .transition(.opacity)
                .background(Color.indigo.ignoresSafeArea())
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // ... существующий код ...
                    }
                    .padding()
                }
                .background(Color(.systemBackground).ignoresSafeArea())
                .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: isInterpreted)
        .alert("Ошибка", isPresented: $viewModel.showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.error?.localizedDescription ?? "Неизвестная ошибка")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    Task {
                        await viewModel.saveDream(interpretation: interpretation)
                        dismiss()
                    }
                }
                .disabled(viewModel.dreamContent.isEmpty || viewModel.selectedMood == nil)
            }
        }
    }
}

struct DreamCreationView_Previews: PreviewProvider {
    static var previews: some View {
        DreamCreationView()
    }
} 
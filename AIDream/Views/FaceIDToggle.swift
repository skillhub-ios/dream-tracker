import SwiftUI
import LocalAuthentication

struct FaceIDToggle: View {
    @AppStorage("useFaceID") private var useFaceID: Bool = false
    @State private var faceIDError: String?
    
    var body: some View {
        HStack {
            Image(systemName: "faceid")
                .font(.system(size: 16))
            Text("Face ID")
                .font(.system(size: 17))
            Spacer()
            Toggle("", isOn: Binding(
                get: { useFaceID },
                set: { newValue in
                    authenticateWithFaceID { success in
                        if success {
                            useFaceID = newValue
                        } else {
                            faceIDError = "Face ID authentication failed"
                        }
                    }
                }
            ))
            .labelsHidden()
        }
        .alert(item: $faceIDError) { error in
            Alert(title: Text("Error"), message: Text(error), dismissButton: .default(Text("OK")))
        }
    }
    
    private func authenticateWithFaceID(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Enable Face ID for extra security"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
                DispatchQueue.main.async {
                    completion(success)
                }
            }
        } else {
            DispatchQueue.main.async {
                completion(false)
            }
        }
    }
}

// Для корректной работы алерта
extension String: Identifiable {
    public var id: String { self }
} 
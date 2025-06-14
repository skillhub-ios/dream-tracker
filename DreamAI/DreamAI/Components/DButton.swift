//
//  DButton.swift
//  DreamAI
//
//  Created by Shaxzod on 07/06/25.
//

import SwiftUI

struct DButton: View {
    let title: String
    let action: () -> Void
    let asyncAction: (() async -> Void)?
    @Binding var isDisabled: Bool
    private var isLoadingBinding: Binding<Bool>?
    
    @State private var internalIsLoading: Bool = false
    
    private var effectiveIsLoading: Binding<Bool> {
        isLoadingBinding ?? .init(
            get: { internalIsLoading },
            set: { internalIsLoading = $0 }
        )
    }
    
    init(
        title: String,
        isDisabled: Binding<Bool> = .constant(false),
        isLoading: Binding<Bool>? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.asyncAction = nil
        self._isDisabled = isDisabled
        self.isLoadingBinding = isLoading
        self.action = action
    }
    
    init(
        title: String,
        isDisabled: Binding<Bool> = .constant(false),
        isLoading: Binding<Bool>? = nil,
        asyncAction: @escaping () async -> Void
    ) {
        self.title = title
        self._isDisabled = isDisabled
        self.isLoadingBinding = isLoading
        self.action = {}
        self.asyncAction = asyncAction
    }
    
    var body: some View {
        Button(action: {
            if let asyncAction = asyncAction {
                Task {
                    effectiveIsLoading.wrappedValue = true
                    await asyncAction()
                    effectiveIsLoading.wrappedValue = false
                }
            } else {
                action()
            }
        }) {
            Text(title)
                .font(.title3.bold())
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(
                            colors: [
                                Color.black.opacity(0.5),
                                Color.purple.opacity(0.7),
                                Color.black.opacity(0.5)
                            ]
                        ),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(13)
                .overlay(
                    RoundedRectangle(cornerRadius: 13)
                        .stroke(Color.purple.opacity(0.4), lineWidth: 1)
                )
        }
        .disabled(isDisabled || effectiveIsLoading.wrappedValue)
        .opacity(isDisabled || effectiveIsLoading.wrappedValue ? 0.65 : 1)
    }
}

#Preview {
    DButton(
        title: "Get Started",
        isDisabled: .constant(true),
        action: {}
    )
    .padding()
}

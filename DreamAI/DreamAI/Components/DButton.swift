//
//  DButton.swift
//  DreamAI
//
//  Created by Shaxzod on 07/06/25.
//

import SwiftUI

// MARK: - DButtonState Enum

enum DButtonState {
    case normal
    case loading
    case tryAgain
    case locked
}

struct DButton: View {
    let title: String
    let state: DButtonState
    let action: () -> Void
    let asyncAction: (() async -> Void)?
    @Binding var isDisabled: Bool
    
    @State private var internalIsLoading: Bool = false
    
    private var effectiveIsLoading: Bool {
        if case .loading = state { return true }
        return false
    }
    
    init(
        title: String,
        state: DButtonState = .normal,
        isDisabled: Binding<Bool> = .constant(false),
        action: @escaping () -> Void
    ) {
        self.title = title
        self.state = state
        self.asyncAction = nil
        self._isDisabled = isDisabled
        self.action = action
    }
    
    init(
        title: String,
        state: DButtonState = .normal,
        isDisabled: Binding<Bool> = .constant(false),
        asyncAction: @escaping () async -> Void
    ) {
        self.title = title
        self.state = state
        self._isDisabled = isDisabled
        self.action = {}
        self.asyncAction = asyncAction
    }
    
    var body: some View {
        Button(action: {
            if let asyncAction = asyncAction {
                Task {
                    internalIsLoading = true
                    await asyncAction()
                    internalIsLoading = false
                }
            } else {
                action()
            }
        }) {
            HStack(spacing: 8) {
                switch state {
                case .normal:
                    Text(title)
                        .font(.title3.bold())
                case .loading:
                    Text("Loading")
                        .font(.title3.bold())
                    MagicLoadingUI(progress: 0.5, lineWidth: 2)
                        .frame(width: 25, height: 25)
                case .tryAgain:
                    Text("Try again")
                        .font(.title3.bold())
                    Image(.magic)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 23, height: 23)
                case .locked:
                    Text("Interpret Dream")
                        .font(.title3.bold())
                    Image(systemName: "lock.fill")
                        .font(.title3)
                }
            }
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
        .disabled(isDisabled || state == .locked || effectiveIsLoading)
        .opacity(isDisabled || state == .locked || effectiveIsLoading ? 0.65 : 1)
        .accessibilityLabel(accessibilityLabel)
    }
    
    private var accessibilityLabel: String {
        switch state {
        case .normal: return title
        case .loading: return "Loading"
        case .tryAgain: return "Try again"
        case .locked: return "Interpret Dream, locked"
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        DButton(title: "Interpret Dream", state: .locked, isDisabled: .constant(false), action: {})
            .padding()
        DButton(title: "Done", state: .normal, isDisabled: .constant(false), action: {})
            .padding()
        DButton(title: "Loading...", state: .loading, isDisabled: .constant(false), action: {})
            .padding()
        DButton(title: "Try again", state: .tryAgain, isDisabled: .constant(false), action: {})
            .padding()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.black)
}

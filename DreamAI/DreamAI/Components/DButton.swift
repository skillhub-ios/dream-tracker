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
    let title: LocalizedStringKey
    @Binding var state: DButtonState
    let action: () -> Void
    let asyncAction: (() async -> Void)?
    @Binding var isDisabled: Bool
    
    @State private var loadingProgress: Double = 0.0
    @State private var timer: Timer? = nil
    
    private var effectiveIsLoading: Bool {
        if case .loading = state { return true }
        return false
    }
    
    init(
        title: LocalizedStringKey,
        state: Binding<DButtonState> = .constant(.normal),
        isDisabled: Binding<Bool> = .constant(false),
        action: @escaping () -> Void
    ) {
        self.title = title
        self._state = state
        self.asyncAction = nil
        self._isDisabled = isDisabled
        self.action = action
    }
    
    init(
        title: LocalizedStringKey,
        state: Binding<DButtonState> = .constant(.normal),
        isDisabled: Binding<Bool> = .constant(false),
        asyncAction: @escaping () async -> Void
    ) {
        self.title = title
        self._state = state
        self._isDisabled = isDisabled
        self.action = {}
        self.asyncAction = asyncAction
    }
    
    var body: some View {
        Button(action: buttonAction) {
            HStack(spacing: 8) {
                switch state {
                case .normal:
                    Text(title)
                        .font(.title3.bold())
                case .loading:
                    Text("loading")
                        .font(.title3.bold())
                    MagicLoadingUI(lineWidth: 2)
                        .frame(width: 25, height: 25)
                case .tryAgain:
                    Text("tryAgain")
                        .font(.title3.bold())
                    Image(.magic)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 23, height: 23)
                case .locked:
                    Text("interpretDream")
                        .font(.title3.bold())
                    Image(systemName: "lock.fill")
                        .font(.title3)
                }
            }
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(isDisabled || effectiveIsLoading)
        .overlay(
            RoundedRectangle(cornerRadius: 13)
                .fill(isDisabled || effectiveIsLoading ? Color.black.opacity(0.5) : Color.clear)
        )
        .onChange(of: state) { _, newState in
            if newState == .loading {
                startLoadingAnimation()
            } else {
                stopLoadingAnimation()
            }
        }
        .onAppear {
            if state == .loading {
                startLoadingAnimation()
            }
        }
        .onDisappear {
            stopLoadingAnimation()
        }
    }
    
    private func startLoadingAnimation() {
        stopLoadingAnimation()
        loadingProgress = 0.0
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            loadingProgress += 0.02
//            if loadingProgress > 1.0 {
//                loadingProgress = 0.0
//            }
        }
    }
    
    private func stopLoadingAnimation() {
        timer?.invalidate()
        timer = nil
        loadingProgress = 0.5 // fallback for static preview
    }

    private func buttonAction() {

        let internalAction = {
            if let asyncAction = asyncAction {
                Task {
                    state = .loading
                    await asyncAction()
                    state = .normal
                }
            } else {
                action()
            }
        }
        switch state {
        case .normal:
            internalAction()
        case .loading:
            startLoadingAnimation()
        case .tryAgain:
            internalAction()
        case .locked:
            break
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        DButton(title: "Interpret Dream", state: .constant(.locked), isDisabled: .constant(false), action: {})
            .padding()
        DButton(title: "Done", state: .constant(.normal), isDisabled: .constant(false), action: {})
            .padding()
        DButton(title: "Loading...", state: .constant(.loading), isDisabled: .constant(false), action: {})
            .padding()
        DButton(title: "Try again", state: .constant(.tryAgain), isDisabled: .constant(false), action: {})
            .padding()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.black)
}

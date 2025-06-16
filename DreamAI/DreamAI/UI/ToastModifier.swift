//
//  ToastModifier.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

enum ToastStyle {
    case error
    // Add more styles as needed
}

struct ToastData: Equatable {
    var style: ToastStyle
    var message: String
    var duration: Double = 3
}

struct ToastModifier<ButtonUI: View>: ViewModifier {
    @Binding var toast: ToastData?
    var retryButtonUI: ButtonUI
    @State private var workItem: DispatchWorkItem?
    
    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
            if let toast = toast {
                ToastView(style: toast.style, message: toast.message, retryButtonUI: retryButtonUI)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 0)
                    .ignoresSafeArea(.container, edges: .bottom)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onAppear { showToast(toast) }
            }
        }
        .animation(.spring(), value: toast)
    }
    
    private func showToast(_ toast: ToastData) {
        workItem?.cancel()
        if toast.duration > 0 {
            let task = DispatchWorkItem {
                dismissToast()
            }
            workItem = task
            DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration, execute: task)
        }
    }
    
    private func dismissToast() {
        withAnimation {
            toast = nil
        }
        workItem?.cancel()
        workItem = nil
    }
}

extension View {
    func toast(toast: Binding<ToastData?>) -> some View {
        self.modifier(ToastModifier(toast: toast, retryButtonUI: EmptyView()))
    }
    
    func toast<ButtonUI: View>(toast: Binding<ToastData?>, retryButtonUI: ButtonUI) -> some View {
        self.modifier(ToastModifier(toast: toast, retryButtonUI: retryButtonUI))
    }
}

private struct ToastView<ButtonUI: View>: View {
    let style: ToastStyle
    let message: String
    let retryButtonUI: ButtonUI
    
    init(style: ToastStyle, message: String, retryButtonUI: ButtonUI) {
        self.style = style
        self.message = message
        self.retryButtonUI = retryButtonUI
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center, spacing: 8) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.appOrange)
                    .tint(.white)
                    .font(.system(size: 24, weight: .bold))
                Text(message)
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(minHeight: 66)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.appOrange.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .shadow(radius: 8)
            
            retryButtonUI
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
        }
    }
}

#Preview {
    @Previewable @State var buttonState: DButtonState = .tryAgain
    VStack {
        Text("Hello, world!")
            .frame(maxHeight: .infinity)
            .toast(
                toast: .constant(
                    ToastData(
                        style: .error,
                        message: "Hello, world!",
                        duration: 3
                    )
                ),
                retryButtonUI: DButton(
                    title: "Try again",
                    state: $buttonState,
                    isDisabled: .constant(false),
                    asyncAction: {
                        try? await Task.sleep(nanoseconds: 10_000_000_000)
                    }
                )
            )
    }
}

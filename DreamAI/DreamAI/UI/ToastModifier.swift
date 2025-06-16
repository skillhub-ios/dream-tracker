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

struct ToastModifier: ViewModifier {
    @Binding var toast: ToastData?
    var retryAction: (() -> Void)?
    @State private var workItem: DispatchWorkItem?

    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
            if let toast = toast {
                ToastView(style: toast.style, message: toast.message, retryAction: retryAction)
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
    func toast(toast: Binding<ToastData?>, retryAction: (() -> Void)? = nil) -> some View {
        self.modifier(ToastModifier(toast: toast, retryAction: retryAction))
    }
}

private struct ToastView: View {
    let style: ToastStyle
    let message: String
    var retryAction: (() -> Void)?

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
            
            
            if let retry = retryAction {
                Button(action: retry) {
                    HStack {
                        Spacer()
                        Text("Try again  ")
                            .font(.headline)
                            .foregroundColor(.white)
                        Image(systemName: "sparkles")
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            .background(Color.clear)
                    )
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
        }
        
    }
} 


#Preview {
    VStack {
        Text("Hello, world!")
            .frame(maxHeight: .infinity)
            .toast(toast: .constant(ToastData(style: .error, message: "Hello, world!", duration: 3)), retryAction: {})
    }
}

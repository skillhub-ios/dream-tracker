//
//  ShimmerView.swift
//  DreamAI
//
//  Created by Shaxzod on 15/06/25.
//

import SwiftUI

struct ShimmerView: ViewModifier {
    let state: ContentStateType
    var retryButtonUI: AnyView? = nil

    @State private var toast: ToastData? = nil

    func body(content: Content) -> some View {
        let mainContent: AnyView = {
            switch state {
            case .loading:
                return AnyView(
                    content
                        .redacted(reason: .placeholder)
                        .disabled(true)
                )
            case .success:
                return AnyView(content)
            case .error(let error):
                DispatchQueue.main.async {
                    toast = ToastData(style: .error, message: error.localizedDescription, duration: 0)
                }
                return AnyView(
                    content
                        .redacted(reason: .placeholder)
                        .disabled(true)
                )
            }
        }()
        return mainContent
            .toast(toast: $toast, retryButtonUI: retryButtonUI)
            .animation(.spring(), value: toast)
            .onChange(of: state) { oldValue, newValue in
                if [ContentStateType.success, ContentStateType.loading].contains(newValue) {
                    toast = nil
                }   
            }
    }
}

extension View {
    func makeShimmer(state: ContentStateType, retryButtonUI: AnyView? = nil) -> some View {
        self.modifier(ShimmerView(state: state, retryButtonUI: retryButtonUI))
    }
}   


#Preview {
    ScrollView {
        VStack(spacing: 20) {
            ForEach(0..<10) { index in
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.appOrange)
                    .frame(height: 100)
            }
        }
    }
    .makeShimmer(state: .error(NSError(domain: "asd", code: 200)), retryButtonUI: AnyView(DButton(title: "Try again", state: .constant(.tryAgain), isDisabled: .constant(false), action: {})))
}

//
//  ShimmerView.swift
//  DreamAI
//
//  Created by Shaxzod on 15/06/25.
//

import SwiftUI

struct ShimmerView: ViewModifier {
    let state: ContentStateType
    var retryAction: (() -> Void)? = nil

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
            .toast(toast: $toast)
            .animation(.spring(), value: toast)
    }
}

extension View {
    func makeshimmer(state: ContentStateType, retryAction: (() -> Void)? = nil) -> some View {
        self.modifier(ShimmerView(state: state, retryAction: retryAction))
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
    .makeshimmer(state: .error(NSError(domain: "asd", code: 200)))
}

//
//  ShimmerView.swift
//  DreamAI
//
//  Created by Shaxzod on 15/06/25.
//

import SwiftUI

struct ShimmerView: ViewModifier {
    let state: ContentStateType

    func body(content: Content) -> some View {
        switch state {
        case .loading:
            content
                .redacted(reason: .placeholder)
        case .success:
            content
        case .error(let error):
            content
        }
    }
}

extension View {
    func makeshimmer(state: ContentStateType) -> some View {
        self.modifier(ShimmerView(state: state))
    }
}   

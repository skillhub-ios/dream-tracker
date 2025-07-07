//
//  MagicLoadingUI.swift
//  DreamAI
//
//  Created by Shaxzod on 11/06/25.
//

import SwiftUI

import SwiftUI

struct MagicLoadingUI: View {
    @State private var animatedProgress: Double = 0.0
    let lineWidth: CGFloat

    init(lineWidth: CGFloat = 4) {
        self.lineWidth = lineWidth
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color.appGray7.opacity(0.37),
                    lineWidth: lineWidth
                )
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    Color.appPurple,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 25), value: animatedProgress)

            Image(.magic)
                .resizable()
                .scaledToFit()
                .padding(6)
        }
        .onAppear {
            animatedProgress = 0.9
        }
    }
}

#Preview {
    MagicLoadingUI(lineWidth: 4)
        .frame(width: 26, height: 26)
}

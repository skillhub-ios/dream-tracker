//
//  MagicLoadingUI.swift
//  DreamAI
//
//  Created by Shaxzod on 11/06/25.
//

import SwiftUI

struct MagicLoadingUI: View {
    let progress: Double
    let lineWidth: CGFloat

    init(progress: Double, lineWidth: CGFloat = 4) {
        self.progress = progress
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
                .trim(from: 0, to: progress)
                .stroke(
                    Color.appPurple,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                // 1
                .animation(.easeOut, value: progress)

            Image(.magic)
                .resizable()
                .scaledToFit()
                .padding(6)
            
        }
    }
}

#Preview {
    MagicLoadingUI(progress: 0.5, lineWidth: 4)
        .frame(width: 26, height: 26)
}

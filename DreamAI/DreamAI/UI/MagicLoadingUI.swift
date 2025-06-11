//
//  MagicLoadingUI.swift
//  DreamAI
//
//  Created by Shaxzod on 11/06/25.
//

import SwiftUI

struct MagicLoadingUI: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color.appGray7.opacity(0.37),
                    lineWidth: 4
                )
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.appPurple,
                    style: StrokeStyle(
                        lineWidth: 4,
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
    MagicLoadingUI(progress: 0.5)
        .frame(width: 26, height: 26)
}

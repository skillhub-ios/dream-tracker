//
//  FloatingActionButton.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

struct FloatingActionButton: View {
    var action: () -> Void = {}
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.2))
                    .frame(width: 72, height: 72)
                Image(systemName: "plus")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color.purple)
            }
        }
        .shadow(color: Color.purple.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack {
            Spacer()
            HStack {
                Spacer()
                FloatingActionButton()
                    .padding(.bottom, 32)
                    .padding(.trailing, 32)
            }
        }
    }
} 
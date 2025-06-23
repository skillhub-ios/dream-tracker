//
//  FloatingActionButton.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

struct FloatingActionButton: View {
    let mode: DreamListItemMode
    var action: () -> Void = {}
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(mode == .edit ? Color.appRed.opacity(0.55) : Color.appPurple.opacity(0.2))
                    .frame(width: 72, height: 72)

                Image(systemName: mode == .edit ? "trash.fill" : "plus")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(mode == .edit ? Color.red : Color.appPurple)
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
                FloatingActionButton(mode: .edit)
                    .padding(.bottom, 32)
                    .padding(.trailing, 32)
            }
        }
    }
} 
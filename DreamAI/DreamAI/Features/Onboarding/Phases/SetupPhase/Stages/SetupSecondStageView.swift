//
// SetupSecondStageView.swift
//
// Created by Cesare on 23.07.2025 on Earth.
// 


import SwiftUI

struct SetupSecondStageView: View {
    var body: some View {
        VStack(spacing: 44) {
            VStack(spacing: 4) {
                Image(.fingerHeart)
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .foregroundStyle(LinearGradient.appPurpleHorizontal)
                    Text("allDone")
                        .font(.body)
                        .foregroundStyle(.white)
                }
            }
            Text("understandHowYouDream")
                .multilineTextAlignment(.center)
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
        }
        .frame(maxHeight: .infinity, alignment: .center)
    }
}

#Preview {
    SetupSecondStageView()
}

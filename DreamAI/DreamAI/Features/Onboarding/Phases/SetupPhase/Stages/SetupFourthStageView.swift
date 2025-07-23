//
// SetupFourthStageView.swift
//
// Created by Cesare on 23.07.2025 on Earth.
//


import SwiftUI
import ImageIO

struct SetupFourthStageView: View {
    
    private let screenWidth: CGFloat = UIScreen.main.bounds.width - 32
    
    var body: some View {
        ZStack(alignment: .top) {
            AnimatedGifView(
                gifName: "celebration",
                width: screenWidth,
                height: screenWidth,
                isPlaying: true
            )
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 48, height: 48)
                    .foregroundStyle(Color.appPurpleGradient3)
                    .padding(.bottom, 12)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("🌙")
                    Text("dreamWorldisReady")
                }
                .font(.largeTitle.bold())
                Text("weMappedSleepHabits")
                    .font(.title2)
                    .foregroundStyle(Color.appPurpleLight.opacity(0.6))
                Text("beginsNowUppercase")
                    .font(.title2.bold())
                    .foregroundStyle(LinearGradient.appPurpleHorizontal)
            }
            .multilineTextAlignment(.center)
            .frame(maxHeight: .infinity, alignment: .center)
        }
    }
}

#Preview {
    NavigationView {
        SetupFourthStageView()
    }
}

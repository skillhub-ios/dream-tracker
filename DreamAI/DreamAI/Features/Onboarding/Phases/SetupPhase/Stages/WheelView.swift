//
// WheelView.swift
//
// Created by Cesare on 06.08.2025 on Earth.
//


import SwiftUI

struct WheelView: View {
    
    @Binding var showActionButton: Bool
    
    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient.darkPurpleToBlack
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Text("winOffer")
                    .font(.title.bold())
                Text("grabPermament")
                    .font(.title2.bold())
                Text("discount")
                    .font(.title2.bold())
                    .foregroundStyle(LinearGradient.appPurpleHorizontal)
                LottieView(
                    animationName: "Fortune",
                    loopMode: .playOnce
                )
                .frame(width: UIScreen.main.bounds.width - 32)
                .aspectRatio(1, contentMode: .fit)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.25) {
                withAnimation {
                    showActionButton = true
                }
            }
        }
        .onAppear {
            showActionButton = false
        }
    }
}

#Preview {
    WheelView(showActionButton: .constant(true))
}

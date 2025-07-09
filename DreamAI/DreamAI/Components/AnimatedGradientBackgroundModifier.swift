//
//  AnimatedGradientBackgroundModifier.swift
//  DreamAI
//
//  Created by Shaxzod on 07/06/25.
//
import SwiftUI

extension View {
    func animatedGradientBackground() -> some View {
        self.modifier(AnimatedGradientBackgroundModifier())
    }
}

struct AnimatedGradientBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            VideoBackgroundView(videoName: "gradientBackground", videoType: "mp4")
                .ignoresSafeArea()

            content
        }    
    }
}

struct AnimatedGradientBackground: View {
    @State private var animate = false
    let gradientColors = [
        Color.black,
        Color.purple.opacity(0.7),
        Color.black,
        Color.purple.opacity(0.4)
    ]
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: gradientColors),
            startPoint: animate ? .topLeading : .topTrailing,
            endPoint: animate ? .bottomTrailing : .bottomLeading
        )
//        .animation(
//            Animation.easeInOut(duration: 6).repeatForever(autoreverses: true),
//            value: animate
//        )
        .onAppear { animate.toggle() }
        .overlay(
            RadialGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.5), .clear]),
                center: .topTrailing,
                startRadius: 60,
                endRadius: 350
            )
        )
    }
}

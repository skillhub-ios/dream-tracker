//
// LottieView.swift
//
// Created by Cesare on 06.08.2025 on Earth.
// 


import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    var animationName: String
    var loopMode: LottieLoopMode = .loop
    var animationSpeed: CGFloat = 1.0

    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)

        let animationView = LottieAnimationView(name: animationName)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.animationSpeed = animationSpeed
        animationView.play()

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        // Устанавливаем ограничения для анимации, чтобы она занимала весь экран
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        // Можно обновлять анимацию при необходимости
    }
}


//
// VideoBackgroundView.swift
//
// Created by Cesare on 09.07.2025 on Earth.
// 

import SwiftUI
import AVKit

struct VideoBackgroundView: UIViewRepresentable {
    let videoName: String
    let videoType: String

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)

        guard let path = Bundle.main.path(forResource: videoName, ofType: videoType) else {
            return view
        }

        let player = AVPlayer(url: URL(fileURLWithPath: path))
        player.isMuted = true
        player.actionAtItemEnd = .none
        player.play()

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = UIScreen.main.bounds
        view.layer.addSublayer(playerLayer)

        // Looping
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            player.seek(to: .zero)
            player.play()
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}


//
// OnboardingFlowViewModel.swift
//
// Created by Cesare on 21.07.2025 on Earth.
// 


import Foundation

final class OnboardingFlowViewModel: ObservableObject {
    @Published var path: [OnboardingStep] = .init()
    @Published private var onboardingComplete: Bool = false
        
    func finishOnboarding() {
        onboardingComplete = true
        NotificationCenter.default.post(
            name: Notification.Name(PublisherKey.onboardingFinished.rawValue),
            object: nil,
            userInfo: ["value": true]
        )
    }
    
    func backToOnboarding() {
        onboardingComplete = false
    }
}

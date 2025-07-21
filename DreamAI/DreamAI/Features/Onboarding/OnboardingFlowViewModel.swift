//
// OnboardingFlowViewModel.swift
//
// Created by Cesare on 21.07.2025 on Earth.
// 


import Foundation

final class OnboardingFlowViewModel: ObservableObject {
    @Published var path: [OnboardingStep] = .init()
}

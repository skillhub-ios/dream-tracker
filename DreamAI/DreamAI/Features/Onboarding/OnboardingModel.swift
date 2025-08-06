//
// OnboardingModel.swift
//
// Created by Cesare on 21.07.2025 on Earth.
// 


import Foundation

enum OnboardingStep: Hashable {
    case onboarding
    case permissions
    case setup
}

enum OnboardingPhase {
    case first
    case second
    case third
    case fourth
}

enum PermissionsPhase: CaseIterable, Identifiable, Equatable {
    case first
    case second
    case third
    case fourth
    
    var id: Self { self }
}

enum SetupPhase {
    case first
    case second
    case third
    case fourth
    case finish
    case wheel
}

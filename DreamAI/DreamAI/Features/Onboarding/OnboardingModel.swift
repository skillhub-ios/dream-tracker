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

enum PermissionsPhase {
    case feel
    case focus
    case personalisation
    case source
}

enum SetupPhase {
    case notifications
    case allDone
    case building
    case dreamWorld
    case save
}

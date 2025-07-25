//
// SetupPhaseView.swift
//
// Created by Cesare on 23.07.2025 on Earth.
// 


import SwiftUI

struct SetupPhaseView: View {
    
    @State private var state: SetupPhase = .second
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var viewModel: OnboardingFlowViewModel
    
    var body: some View {
        ZStack {
            LinearGradient.darkPurpleToBlack
                .ignoresSafeArea()
            VStack {
                content
                Spacer(minLength: .zero)
                if !actionButtonIsHidded() {
                    Button {
                        swithState()
                    } label: {
                        Text(actionButtonLabel)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.horizontal, 16)
        }
        .navigationBarHidden(true)
    }
}

private extension SetupPhaseView {
    @ViewBuilder var content: some View {
        switch state {
//        case .first: PermissionSettingsView()
        case .second: SetupSecondStageView()
        case .third: SetupThirdView(stage: $state)
        case .fourth: SetupFourthStageView()
        case .finish: OnboardingFinishView()
        }
    }
    
    var actionButtonLabel: LocalizedStringKey {
        switch state {
//        case .first: "done"
        case .second: "continue"
        case .fourth: "startJourney"
        case .third, .finish: ""
        }
    }
    
    func actionButtonIsHidded() -> Bool {
        switch state {
        case .third, .finish: true
        default: false
        }
    }
    
    func swithState() {
        switch state {
//        case .first:
//            state = .second
        case .second:
            state = .third
        case .fourth:
            if authManager.isAuthenticated {
                viewModel.finishOnboarding()
            } else {
                state = .finish
            }
        default: break
        }
    }
}

#Preview {
    NavigationView {
        SetupPhaseView()
    }
    .environmentObject(OnboardingFlowViewModel())
    .environmentObject(AuthManager.shared)
}

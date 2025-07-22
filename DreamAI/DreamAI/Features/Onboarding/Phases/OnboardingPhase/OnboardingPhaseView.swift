//
// OnboardingPhaseView.swift
//
// Created by Cesare on 21.07.2025 on Earth.
//


import SwiftUI

struct OnboardingPhaseView: View {
    
    @EnvironmentObject private var onboardingViewModel: OnboardingFlowViewModel
    @State private var state: OnboardingPhase = .third
    
    var body: some View {
        ZStack {
            LinearGradient.darkPurpleToBlack
                .ignoresSafeArea()
            VStack {
                content
                    .padding(.top, 40)
                Spacer()
                Button {
                    withAnimation(.spring()) {
                        swithState()
                    }
                } label: {
                    Text(actionButtonTitle)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.horizontal, 16)
        }
    }
}

private extension OnboardingPhaseView {
    @ViewBuilder var content: some View {
        switch state {
        case .first: OnboardingFirstStageView()
        case .second: OnboardingSecondPhaseView()
        case .third: OnboardingThirdPhaseView()
        case .fourth: OnboardingFouthPhaseView()
        }
    }
    
    func swithState() {
        switch state {
        case .first:
            state = .second
        case .second:
            state = .third
        case .third:
            state = .fourth
        case .fourth:
            onboardingViewModel.path.append(.permissions)
        }
    }
    
    var actionButtonTitle: LocalizedStringKey {
        switch state {
        case .first: "showMeHow"
        case .second: "seeMagic"
        case .third: "continue"
        case .fourth: "startDreamJourney"
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingPhaseView()
            .environmentObject(OnboardingFlowViewModel())
    }
}

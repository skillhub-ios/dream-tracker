//
// OnboardingFinishView.swift
//
// Created by Cesare on 23.07.2025 on Earth.
//


import SwiftUI

struct OnboardingFinishView: View {
    
    @Environment(\.deviceFamily) private var deviceFamily
    @EnvironmentObject private var onboardingViewModel: OnboardingFlowViewModel
    
    var body: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 48, height: 48)
                .foregroundStyle(Color.appPurpleGradient3)
            Text("saveProgress")
                .font(.largeTitle)
        }
        .frame(maxHeight: .infinity, alignment: .center)
        .sheet(isPresented: .constant(true)) {
            AuthSheetView(mode: .signup, isSkipAllowed: true) {
                onboardingViewModel.finishOnboarding()
            }
            .presentationDetents([.fraction(sheetHeight())])
            .interactiveDismissDisabled(true)
        }
    }
    
    private func sheetHeight() -> CGFloat {
        switch deviceFamily {
        case .pad: 0.4
        case .phone: 0.34
        }
    }
}

#Preview {
    OnboardingFinishView()
        .environmentObject(OnboardingFlowViewModel())
}

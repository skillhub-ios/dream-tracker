//
// PermissionsView.swift
//
// Created by Cesare on 22.07.2025 on Earth.
//


import SwiftUI

struct PermissionsView: View {
    
    @EnvironmentObject private var onboardingViewModel: OnboardingFlowViewModel
    @State private var state: PermissionsPhase = .first
    
    var body: some View {
        ZStack {
            LinearGradient.darkPurpleToBlack
                .ignoresSafeArea()
            VStack(spacing: 24) {
                paginationIndicator
                content
                Spacer()
                buttonFooterView
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.horizontal, 16)
        }
        .navigationBarHidden(true)
    }
}

private extension PermissionsView {
    var paginationIndicator: some View {
        HStack(spacing: 8) {
            ForEach(PermissionsPhase.allCases) { phase in
                Capsule()
                    .frame(width: 28, height: 5)
                    .foregroundColor(phase == state ? Color.appPurple : Color.white.opacity(0.18))
            }
        }
        .padding(.top, 20)
    }
    
    @ViewBuilder var content: some View {
        switch state {
        case .first: PermissionsFeelingsUI()
        case .second: PermissionsLifeFocusUI()
        case .third: PermissionsPersonalizationUI()
        case .fourth: ReferralSourceUI()
        }
    }
    
    var buttonFooterView: some View {
        VStack(spacing: 12) {
            Button {
                withAnimation(.spring()) {
                    swithState()
                }
            } label: {
                Text("next")
            }
            .buttonStyle(PrimaryButtonStyle())
            
            Button {
                onboardingViewModel.path.append(.setup)
            } label: {
                Text("skip")
            }
            .buttonStyle(SkipStyle())
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
            onboardingViewModel.path.append(.setup)
        }
    }
}

#Preview {
    NavigationStack {
        PermissionsView()
            .environmentObject(OnboardingFlowViewModel())
    }
}

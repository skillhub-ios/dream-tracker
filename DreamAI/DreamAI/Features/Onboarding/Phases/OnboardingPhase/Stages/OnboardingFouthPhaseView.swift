//
// OnboardingFouthPhaseView.swift
//
// Created by Cesare on 21.07.2025 on Earth.
// 


import SwiftUI

struct OnboardingFouthPhaseView: View {
    var body: some View {
        VStack(spacing: 32) {
            OnboardingPhaseTitleView(title: "onboardingFouthStageTitle")
            OnboardingPhaseInterpretationView()
            simbolsView
        }
    }
}

private extension OnboardingFouthPhaseView {
    var simbolsView: some View {
        VStack(spacing: 24) {
            HStack(spacing: 24) {
                simbolView(.ask)
                simbolView(.keep)
            }
            simbolView(.create)
        }
    }
    
    func simbolView(_ simbol: OnboardingSimbol) -> some View {
        VStack {
            ZStack {
                Color.appPurpleDarkStroke
                Image(systemName: simbol.image)
                    .font(.system(size: 24))
                    .foregroundStyle(Color.appPurpleGradient3)
            }
            .clipShape(Circle())
            .frame(width: 52, height: 52)
            Text(simbol.title)
                .multilineTextAlignment(.center)
                .font(.body)
                .lineLimit(2)
        }
        .frame(maxWidth: 160)
    }
}

fileprivate enum OnboardingSimbol {
    case ask, keep, create
    
    var title: LocalizedStringKey {
        switch self {
        case .ask: "onboardingSimbolAsk"
        case .keep: "onboardingSimbolKeep"
        case .create: "onboardingSimbolCreate"
        }
    }
    
    var image: String {
        switch self {
        case .ask: "moon.stars.fill"
        case .keep: "lock.fill"
        case .create: "book.fill"
        }
    }
}

#Preview {
    OnboardingFouthPhaseView()
}

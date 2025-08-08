//
// SetupPhaseView.swift
//
// Created by Cesare on 23.07.2025 on Earth.
//


import SwiftUI

struct SetupPhaseView: View {
    
    @State private var state: SetupPhase = .first
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var viewModel: OnboardingFlowViewModel
    @EnvironmentObject private var subscriptionViewModel: SubscriptionViewModel
    @State private var isWaitingForAuth = false
    @State private var showActionButton: Bool = true
    
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
                    .opacity(showActionButton ? 1 : 0)
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.horizontal, 16)
        }
        .navigationBarHidden(true)
        .onReceive(authManager.$isAuthenticated) { isAuthenticated in
            // Реагируем только если ждем результат авторизации
            if isWaitingForAuth {
                isWaitingForAuth = false
                // Показываем paywall независимо от результата
                showPaywallAndHandleResult()
            }
        }
        .onReceive(subscriptionViewModel.$isSubscribed) { isSubscribed in
            // если получили собыите подписки, то завершаем
            if isSubscribed {
                viewModel.finishOnboarding()
            }
        }
    }
}

private extension SetupPhaseView {
    @ViewBuilder var content: some View {
        switch state {
        case .first: PermissionSettingsView()
        case .second: SetupSecondStageView()
        case .third: SetupThirdView(stage: $state)
        case .fourth: SetupFourthStageView()
        case .finish: OnboardingFinishView()
        case .wheel: WheelView(showActionButton: $showActionButton)
        }
    }
    
    var actionButtonLabel: LocalizedStringKey {
        switch state {
        case .first: "done"
        case .second, .wheel: "continue"
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
        case .first:
            state = .second
        case .second:
            state = .third
        case .fourth:
            if authManager.isAuthenticated && subscriptionViewModel.isSubscribed {
                // если авторизирован и есть премиум, то завешаем
                viewModel.finishOnboarding()
            } else if authManager.isAuthenticated && !subscriptionViewModel.isSubscribed {
                // если авторизирован и нет премиум, то показываем первый paywall
                showPaywallAndHandleResult()
            } else {
                // если не аторизовн и есть подписка, то ждем авторизацию
                isWaitingForAuth = true
                state = .finish
            }
        case .wheel: print()
            // paywall со скидкой. Вне зависимости от результата завершаем
            subscriptionViewModel.showPaywallWithCompletionDiscount { _ in
                viewModel.finishOnboarding()
            }
        default: break
        }
    }
    
    private func showPaywallAndHandleResult() {
        subscriptionViewModel.showPaywallWithCompletionDefault { result in
            switch result {
            case .dismissed:
                // если ничего не купил то ведем на колесо
                self.state = .wheel
            case .purchased:
                // если купил/восстановил то завершаем
                self.viewModel.finishOnboarding()
            }
        }
    }
}

#Preview {
    NavigationView {
        SetupPhaseView()
    }
    .environmentObject(OnboardingFlowViewModel())
    .environmentObject(AuthManager.shared)
    .environmentObject(PushNotificationManager.shared)
    .environmentObject(BiometricManagerNew())
    .environmentObject(SubscriptionViewModel())
}

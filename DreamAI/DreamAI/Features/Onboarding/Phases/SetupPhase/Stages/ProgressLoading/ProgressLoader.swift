//
// ProgressLoader.swift
//
// Created by Cesare on 23.07.2025 on Earth.
//


import SwiftUI

@MainActor
class ProgressLoader: ObservableObject {
    @Published var currentProgress: Double = 0.0
    @Published var isLoading: Bool = false
    
    private var animationTimer: Timer?
    private var currentStep = 0
    
    // Конфигурация шагов загрузки
    private let loadingSteps: [(target: Double, duration: Double, pauseDuration: Double)] = [
        (target: 20.0, duration: 2.0, pauseDuration: 0.3),   // 0% -> 20%
        (target: 70.0, duration: 3.0, pauseDuration: 0.5),   // 20% -> 70%
        (target: 100.0, duration: 1.5, pauseDuration: 0.0)   // 70% -> 100%
    ]
    
    func startLoading() {
        guard !isLoading else { return }
        
        isLoading = true
        currentProgress = 0.0
        currentStep = 0
        
        executeNextStep()
    }
    
    func resetProgress() {
        isLoading = false
        currentProgress = 0.0
        currentStep = 0
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func executeNextStep() {
        guard currentStep < loadingSteps.count else {
            // Загрузка завершена
            isLoading = false
            return
        }
        
        let step = loadingSteps[currentStep]
        
        // Тактильный фидбек в момент начала изменения значения
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Анимация прогресса до целевого значения
        withAnimation(.easeInOut(duration: step.duration)) {
            currentProgress = step.target
        }
        
        // Планируем следующий шаг после паузы
        DispatchQueue.main.asyncAfter(deadline: .now() + step.duration + step.pauseDuration) {
            self.currentStep += 1
            self.executeNextStep()
        }
    }
}

//
// SetupThirdView.swift
//
// Created by Cesare on 23.07.2025 on Earth.
// 


import SwiftUI

struct SetupThirdView: View {
    
    @Binding var stage: SetupPhase
    @StateObject private var progressLoader = ProgressLoader()
    
    var body: some View {
        VStack(spacing: 64) {
            headerView
            footerView
        }
        .frame(maxHeight: .infinity, alignment: .center)
        .onAppear {
            if stage == .third {
                progressLoader.startLoading()
            }
        }
        .onChange(of: progressLoader.isLoading) { oldValue, newValue in
            if oldValue && !newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    stage = .fourth
                }
            }
        }
    }
}

private extension SetupThirdView {
    var headerView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                AnimatedNumberView(value: progressLoader.currentProgress)
                Text("buildingDreamProfile")
                    .font(.title2)
            }
            VStack {
                CustomProgressBar(progress: progressLoader.currentProgress)
                Text("analyzingYourDream")
                    .font(.callout)
            }
        }
    }
    
    var footerView: some View {
        VStack(spacing: 16) {
            Text("weCombining")
                .font(.title3.bold())
            VStack(alignment: .leading, spacing: 12) {
                ForEach(ProgressStep.allCases, id: \.self) { step in
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark")
                        Text(step.title)
                            .font(.body)
                    }
                }
            }
        }
        .foregroundStyle(.white)
    }
}

#Preview {
    SetupThirdView(stage: .constant(.second))
}

private enum ProgressStep: CaseIterable {
    case dreams, focus, beliefs
    
    var title: LocalizedStringKey {
        switch self {
        case .dreams: "dreamStyles"
        case .focus: "focusAreas"
        case .beliefs: "personalBeliefs"
        }
    }
}

struct AnimatedNumberView: View {
    let value: Double
    
    var body: some View {
        Text("\(Int(value))%")
            .font(.system(size: 48, weight: .bold, design: .default))
            .contentTransition(.numericText(value: value))
            .animation(.easeInOut(duration: 0.3), value: value)
    }
}

struct CustomProgressBar: View {
    let progress: Double
    let height: CGFloat = 10
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Фон прогресс-бара
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.appGray7.opacity(0.36))
                    .frame(height: height)
                
                // Заполненная часть
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient.appPurpleHorizontal
                    )
                    .frame(
                        width: geometry.size.width * (progress / 100.0),
                        height: height
                    )
                    .animation(.easeInOut(duration: 0.3), value: progress)
                
                // Блик эффект
                if progress > 0 {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0),
                                    .white.opacity(0.3),
                                    .white.opacity(0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * (progress / 100.0),
                            height: height
                        )
                }
            }
        }
        .frame(height: height)
    }
}

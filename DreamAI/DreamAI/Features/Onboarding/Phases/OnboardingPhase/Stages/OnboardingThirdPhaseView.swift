//
// OnboardingThirdPhaseView.swift
//
// Created by Cesare on 21.07.2025 on Earth.
//


import SwiftUI

struct OnboardingThirdPhaseView: View {
    var body: some View {
        VStack(spacing: 24) {
            OnboardingPhaseTitleView(
                title: "onboardingThirdStageTitle",
                subtitle: "onboardingThirdStageSubtitle")
            VStack(spacing: 12) {
                ForEach(OnboardingDream.allCases) { dream in
                    dreamCartView(dream)
                }
            }
            Image(.faces)
        }
    }
}

private extension OnboardingThirdPhaseView {
    func dreamCartView(_ dream: OnboardingDream) -> some View {
        HStack(spacing: .zero) {
            HStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(dream.color)
                        .frame(width: 54, height: 54)
                    Text(dream.image)
                        .font(.system(size: 24, weight: .semibold, design: .default))
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(dream.title)
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    HStack {
                        ForEach(Array(dream.tags.enumerated()), id: \.offset) { _, tag in
                            tagView(tag: tag)
                                
                        }
                    }
                }
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing) {
                Text(dream.date.asShortDateString())
                Text(dream.date.asShortTimeString())
            }
            .font(.footnote)
            .foregroundStyle(Color.appGray9.opacity(0.6))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .background {
            RoundedRectangle(cornerRadius: 27)
                .fill(Color.appGray3)
        }
    }
    
    func tagView(tag: LocalizedStringKey) -> some View {
        Text(tag)
            .lineLimit(1)
            .font(.footnote)
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background {
                RoundedRectangle(cornerRadius: 40)
                    .fill(Color.appGray7)
            }
    }
}

#Preview {
    OnboardingThirdPhaseView()
        .padding(.horizontal, 16)
}

fileprivate enum OnboardingDream: Identifiable, CaseIterable {
    case fly, forgot, talk
    
    var id: Self { self }
    
    var title: LocalizedStringKey {
        switch self {
        case .fly:
            return "onboardingDreamFly"
        case .forgot:
            return "onboardingDreamForgot"
        case .talk:
            return "onboardingDreamTalk"
        }
    }
    
    var tags: [LocalizedStringKey] {
        switch self {
        case .fly: ["supernaturalDream"]
        case .forgot: ["sleepParalysis"]
        case .talk: ["flying", "freedom"]
        }
    }
    
    var color: Color {
        switch self {
        case .fly: .cyan
        case .forgot: .red
        case .talk: .green
        }
    }
    
    var image: String {
        switch self {
        case .forgot: "😰"
        default: "☁️"
        }
    }
    
    var date: Date {
        switch self {
        case .fly:
            return Self.makeDate(year: 2025, month: 7, day: 1, hour: 8, minute: 13)
        case .forgot:
            return Self.makeDate(year: 2025, month: 6, day: 30, hour: 5, minute: 22)
        case .talk:
            return Self.makeDate(year: 2025, month: 6, day: 29, hour: 9, minute: 36)
        }
    }
    
    private static func makeDate(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components)!
    }
}

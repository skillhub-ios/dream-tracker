//
//  DreamInterpretationView.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

struct DreamInterpretationView: View {
    
    @StateObject private var viewModel: DreamInterpretationViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(dream: Dream) {
        self._viewModel = StateObject(wrappedValue: DreamInterpretationViewModel(dream: dream))
    }
    
    private var model: Interpretation {
        viewModel.interpretation ?? dreamInterpretationFullModel }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Title
                    Text(model.dreamTitle)
                        .font(.title)
                        .foregroundStyle(
                            .linearGradient(
                                colors: [Color(hex: "BF5AF2"), Color(hex: "DA8FFF")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    // Dream description
                    dreamDescription
                    
                    // Progress bars and tags
                    HStack(spacing: 16) {
                        moodProgressUI(model.moodInsights)
                        
                        dreamTypeUI(model.symbolism)
                        
                    }
                    .frame(height: 105)
                    
                    // Interpretation
                    interpretationTextUI(model.fullInterpretation)
                    
                    // Real reflections (collapsible)
                    DisclosureGroup {
                        Text(model.reflectionPrompts.joined())
                            .font(.body)
                            .foregroundColor(.appWhite)
                    } label: {
                        Text("🔍  Real reflections")
                            .font(.headline)
                            .foregroundColor(.appWhite)
                    }
                    .tint(.appPurple)
                    .padding()
                    .background(Color.appPurpleDarkBackground)
                    .cornerRadius(16)
                    
                    // Quote
                    quoteUI(quote: model.quote)
                    
                    // Resonance
                    resonanceUI($viewModel.selectedResonance)
                    
                    // Done button
                    DButton(
                        title: "Done",
                        state: $viewModel.buttonState,
                        action: { dismiss() })
                }
                .padding()
            }
            .makeshimmer(state: viewModel.contentState, retryButtonUI: retryButtonUI($viewModel.buttonState))
            .navigationTitle("Dream Interpretation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.medium)
                    .foregroundColor(.appPurple)
                }
            }
        }
    }
}

//MARK: - private UI
private extension DreamInterpretationView {
    
    var dreamDescription: some View {
        Text(model.dreamSummary)
            .font(.body)
            .foregroundColor(.appWhite)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.appPurple, lineWidth: 1)
                    .fill(Color.appPurpleDarkBackground)
            )
    }
    
    func moodProgressUI(_ feelingProgress: [MoodInsight]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(feelingProgress, id: \.emoji) { item in
                HStack {
                    Text(item.emoji)
                    MoodProgressUI(progress: item.score)
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .frame(maxHeight: .infinity)
        .background{
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.appPurpleDarkBackground)
        }
    }
    
    func dreamTypeUI(_ dreamTags: [SymbolMeaning]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(dreamTags, id: \.icon) { tag in
                Text("\(tag.icon) \(tag.meaning)")
                    .font(.subheadline)
                    .foregroundColor(.appWhite)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .frame(maxHeight: .infinity)
        .background{
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appPurpleDarkBackground)
        }
    }
    
    func interpretationTextUI(_ interpretation: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🧠  Interpretation")
                .font(.headline)
                .foregroundColor(.appWhite)
            
            Text(interpretation)
                .font(.body)
                .foregroundColor(.appWhite)
        }
        .padding()
        .background(Color.appPurpleDarkBackground)
        .cornerRadius(16)
    }
    
    func quoteUI(quote: Quote) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("✨ '\(quote.text)'\n— \(quote.author)")
                .font(.body.italic())
                .foregroundColor(.appWhite)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(Color.appPurpleDarkBackground)
        .cornerRadius(16)
    }
    
    func resonanceUI(_ selectedResonance: Binding<ResonanceOption>) -> some View {
        HStack(spacing: 15) {
            ForEach(ResonanceOption.allCases, id: \.self) { option in
                Button(action: { selectedResonance.wrappedValue = option }) {
                    Text(option.rawValue)
                        .font(.body)
                        .foregroundColor(.appWhite)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedResonance.wrappedValue == option ? Color.appPurpleDarkStroke : Color.appGray8.opacity(0.24))
                        )
                }
            }
        }
    }
    
    func retryButtonUI(_ buttonState: Binding<DButtonState>) -> AnyView {
        AnyView(
            DButton(title: "Try again", state: buttonState) {
                
            }
        )
    }
}

//MARK: - MoodProgressUI
struct MoodProgressUI: View {
    var progress: Double
    
    private var clampedProgress: Double {
           min(progress, 1.0)
       }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.appGray7.opacity(0.36))
                    .frame(height: 10)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.appPurple)
                    .frame(width: geometry.size.width * CGFloat(clampedProgress), height: 10)
            }
        }
        .frame(height: 10)
    }
}


#Preview {
    VStack {
        Text("Hello")
            .sheet(isPresented: .constant(true)) {
                DreamInterpretationView(dream: loadMockDreams().first!)
            }
    }
}

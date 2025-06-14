//
//  DreamInterpretationView.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

struct DreamInterpretationView: View {
    @StateObject private var viewModel = DreamInterpretationViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Dream description
                    dreamDescription
                    
                    // Progress bars and tags
                    HStack(spacing: 16) {
                        moodProgressUI(viewModel.feelingProgress)
                        
                        dreamTypeUI(viewModel.tags)
                        
                    }
                    .frame(height: 105)
                    
                    // Interpretation
                    interpretationTextUI(viewModel.interpretation)
                    
                    // Real reflections (collapsible)
                    DisclosureGroup {
                        Text(viewModel.realReflections)
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
                    quoteUI(viewModel.quote, "Some One")
                    
                    // Done button
                    DButton(title: "Done", action: {})
                }
                .padding()
            }
            .background(Color.appPurpleDark.ignoresSafeArea())
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
        Text(viewModel.dreamDescription)
            .font(.body)
            .foregroundColor(.appWhite)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.appPurple, lineWidth: 1)
                    .fill(Color.appPurpleDarkBackground)
            )
    }
    
    func moodProgressUI(_ feelingProgress: [FeelingProgress]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(feelingProgress, id: \.emoji) { item in
                HStack {
                    Text(item.emoji)
                    MoodProgressUI(progress: item.progress)
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
    
    func dreamTypeUI(_ dreamTags: [DreamTag]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(dreamTags, id: \.self) { tag in
                Text("\(tag.icon) \(tag.title)")
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
    
    func quoteUI(_ quote: String, _ author: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("✨ '\(quote)'\n— \(author)")
                .font(.body.italic())
                .foregroundColor(.appWhite)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(Color.appPurpleDarkBackground)
        .cornerRadius(16)
    }
}

//MARK: - MoodProgressUI
struct MoodProgressUI: View {
    var progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.appGray7.opacity(0.36))
                    .frame(height: 10)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.appPurple)
                    .frame(width: geometry.size.width * CGFloat(progress), height: 10)
            }
        }
        .frame(height: 10)
    }
}


#Preview {
    VStack {
        Text("Hello")
            .sheet(isPresented: .constant(true)) {
                DreamInterpretationView()
            }
    }
}

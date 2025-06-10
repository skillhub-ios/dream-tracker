//
//  ReferralSourceUI.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

struct ReferralSourceUI: View {
    @StateObject private var viewModel = ReferralSourceViewModel()
    var onNext: (() -> Void)?
    var onSkip: (() -> Void)?
    
    var body: some View {
        ZStack{
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color.appPurpleDark,
                        Color.black
                    ]
                ),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 10) {
                Text("How did you hear about us?")
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                card
                Spacer()
                nextButton
                skipButton
            }
            .padding([.horizontal, .top], 16)
        }
    }
    
    private var card: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                ForEach(viewModel.allSources) { source in
                    Button(action: {
                        viewModel.toggleSource(source)
                    }) {
                        HStack {
                            Text(source.title)
                                .font(.system(size: 19))
                                .foregroundColor(.white)
                            Spacer()
                            if viewModel.selectedSources.contains(source) {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .foregroundColor(.purple)
                                    .frame(width: 24, height: 24)
                            } else {
                                Image(systemName: "circle")
                                    .resizable()
                                    .foregroundColor(Color.white.opacity(0.3))
                                    .frame(width: 24, height: 24)
                            }
                        }
                        .frame(height: 44)
                    }
                    if viewModel.allSources.last != source {
                        Divider()
                    }
                }
            }
            .padding(10)
            .background(Color.appPurpleDark.mix(with: .white, by: 0.05).opacity(0.75))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(16)
        .background(Color.appPurpleDark)
        .cornerRadius(16)
    }
    
    private var nextButton: some View {
        DButton(title: "Next") {
            onNext?()
        }
            .disabled(!viewModel.canProceed)
            .padding(.bottom, 4)
    }
    
    private var skipButton: some View {
        Button(action: { onSkip?() }) {
            Text("Skip")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
        .accessibilityLabel("Skip")
    }
}

#Preview {
    ReferralSourceUI()
        .background(Color.black)
} 

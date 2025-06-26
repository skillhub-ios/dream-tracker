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
            AppGradients.purpleToBlack
                .ignoresSafeArea()
            VStack(spacing: 10) {
                Text("How did you hear about us?")
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                card
                Spacer()
                buttonsContainerView
            }
            .padding([.horizontal, .top], 16)
        }
    }
}

private extension ReferralSourceUI {
    var card: some View {
        VStack(spacing: .zero) {
            VStack(spacing: .zero) {
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
                                    .frame(width: 22, height: 22)
                            } else {
                                Image(systemName: "circle")
                                    .resizable()
                                    .foregroundColor(Color.white.opacity(0.3))
                                    .frame(width: 22, height: 22)
                            }
                        }
                        .frame(height: 44)
                        .padding(.horizontal, 16)
                    }
                    if viewModel.allSources.last != source {
                        Divider()
                    }
                }
            }
            .background(Color.appPurpleDark.mix(with: .white, by: 0.05).opacity(0.75))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(16)
        .background(Color.appPurpleDark)
        .cornerRadius(16)
    }
    
    var buttonsContainerView: some View {
        VStack(spacing: 12) {
            Button {
                onNext?()
            } label: {
                Text("Next")
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!viewModel.canProceed)
            
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
}

#Preview {
    ReferralSourceUI()
        .background(Color.black)
}

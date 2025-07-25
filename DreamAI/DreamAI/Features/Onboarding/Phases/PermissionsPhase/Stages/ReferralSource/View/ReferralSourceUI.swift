//
//  ReferralSourceUI.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

struct ReferralSourceUI: View {
    @StateObject private var viewModel = ReferralSourceViewModel()
    
    var body: some View {
        VStack(spacing: 10) {
            Text("howDidHear")
                .font(.title2.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            card
        }
    }
    
    private var card: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                ForEach(ReferralSource.allCases) { source in
                    Button(action: {
                        viewModel.toggleSource(source)
                    }) {
                        HStack {
                            Text(source.displayName)
                                .font(.system(size: 19))
                                .foregroundColor(.white)
                            Spacer()
                            if viewModel.selectedSources.contains(source) {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .foregroundStyle(LinearGradient.appPurpleHorizontal)
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
                    if source != .other {
                        Divider()
                    }
                }
            }
            .padding(.horizontal, 16)
            .background(Color.appPurpleDark.mix(with: .white, by: 0.05).opacity(0.75))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(16)
        .background(Color.appPurpleDark)
        .cornerRadius(16)
    }
}

#Preview {
    ReferralSourceUI()
        .background(Color.black)
}

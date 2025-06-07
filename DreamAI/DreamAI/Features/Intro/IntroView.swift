//
//  IntroView.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

struct IntroView: View {
    @State private var animateGradient = false
    @State private var showAuthSheet = false
    
    var body: some View {
        VStack {
            Spacer()
            IntroBottomCard(showAuthSheet: $showAuthSheet)
        }
        .animatedGradientBackground()
        .sheet(isPresented: $showAuthSheet) {
            AuthSheetView(mode: .login)
                .presentationDetents([.fraction(0.28)])
                .presentationDragIndicator(.visible)
        }
    }
}

struct IntroBottomCard: View {
    @Binding var showAuthSheet: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading) {
                HStack(alignment: .center, spacing: 8) {
                    Image(systemName: "moon.stars.fill")
                        .foregroundColor(.yellow)
                        .font(.title2)
                    Text("Uncover Your Dreams with AI")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                }
                Text("Explore your subconscious, one dream at a time.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
            }
            
            Button(action: {}) {
                Text("Get Started")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(
                                colors: [
                                    Color.black.opacity(0.5),
                                    Color.purple.opacity(0.7),
                                    Color.black.opacity(0.5)
                                ]
                            ),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 13)
                            .stroke(Color.purple.opacity(0.4), lineWidth: 1)
                    )
            }
            .padding(.horizontal, 8)
            HStack(spacing: 4) {
                Text("Do you already have an account?")
                    .foregroundColor(.white)
                    .font(.footnote)
                Button(action: { showAuthSheet = true }) {
                    Text("Log in")
                        .underline()
                        .foregroundColor(.white)
                        .font(.footnote.bold())
                }
            }
            .padding(.bottom, 8)
        }
        
    }
}

#Preview {
    IntroView()
        .preferredColorScheme(.dark)
}

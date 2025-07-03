//
// DreamDetailsView.swift
//
// Created by Cesare on 02.07.2025 on Earth.
// 


import SwiftUI

struct DreamDetailsView: View {
    
    @EnvironmentObject private var subscriptionViewModel: SubscriptionViewModel
    @State private var isShowingInterpretation: Bool = false
    @Environment(\.dismiss) private var dismiss
    private let dream: Dream
    
    init(dream: Dream) {
        self.dream = dream
    }
    
    var body: some View {
        ZStack {
            Color.appGray4
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 12) {
                    DreamDateView(date: .constant(dream.date), isCreating: false)
                    ZStack(alignment: .topLeading) {
                        Color.appGray1
                        Text(dream.title)
                            .font(.system(size: 17))
                            .padding(.vertical, 18)
                            .padding(.horizontal, 16)
                    }
                    .frame(maxWidth: .infinity, minHeight: SCREEN_HEIGHT * 0.3)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    Spacer()
                    
                    DButton(title: "Interpret Dream") {
                        if subscriptionViewModel.isSubscribed {
                            isShowingInterpretation = true
                        } else {
                            subscriptionViewModel.showPaywall()
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .navigationTitle("Dream Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .foregroundColor(.appPurple)
                }
            }
        }
        .onChange(of: isShowingInterpretation) {
            if !isShowingInterpretation {
                dismiss()
            }
        }
        .sheet(isPresented: $isShowingInterpretation) {
            DreamInterpretationView(dream: dream)
        }
    }
}

#Preview {
    NavigationStack {
        DreamDetailsView(dream: loadMockDreams().last!)
    }
}

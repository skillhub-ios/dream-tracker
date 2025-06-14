//
//  MainView.swift
//  DreamAI
//
//  Created by Shaxzod on 10/06/25.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                lineGradient
                
                VStack {
                    VStack(spacing: 0) {
                        Text("Good morning!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Ready to log a dream?")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                            .padding(.top, 10)
                        
                        VStack {
                            if let lastDream = viewModel.lastDream {
                                lastDreamView(lastDream: lastDream)
                            } else {
                                noDreamsView
                            }
                        }
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    
                    Color.clear
                        .frame(height: SCREEN_HEIGHT * 0.7)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(systemName: "person.circle")
                        .font(.title)
                        .foregroundStyle(.white)
                }
            }
            .sheet(isPresented: .constant(true)) {
                MainFloatingPanelView()
                    .presentationDetents([.fraction(0.7), .large])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(.ultraThickMaterial)
                    .presentationBackgroundInteraction(.enabled)
                    .presentationBackground(Color.red)
                    .interactiveDismissDisabled()
                    .environmentObject(viewModel)
            }
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
    }
}

// Mark: private UI

private extension MainView {
    var lineGradient: some View {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    Color(.sRGB, red: 38/255, green: 18/255, blue: 44/255, opacity: 1),
                    Color.black
                ]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    func lastDreamView(lastDream dream: Dream) -> some View {
        HStack(spacing: 12) {
            Text(dream.emoji)
                .frame(width: 24, height: 24)
                .padding(5)
                .background(Color.appPurpleDarkBackground)
                .clipShape(Circle())
            
            Text(dream.date.formatted())
                .font(.caption)
                .foregroundStyle(.gray)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.appPurpleDark.opacity(0.5))
        .clipShape(Capsule())
        .padding(.top)
    }
    
    var noDreamsView: some View {
        HStack(spacing: 12) {
            Text("😞")
                .frame(width: 24, height: 24)
                .padding(5)
                .background(Color.appPurpleDarkBackground)
                .clipShape(Circle())
            
            Text("No dreams yet")
                .font(.caption)
                .foregroundStyle(.gray)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.appPurpleDark.opacity(0.5))
        .clipShape(Capsule())
        .padding(.top)
    }
}

extension Date {
    /// from Date  to -> 2.07.2023 • 05:20
    func formatted() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy • HH:mm"
        return dateFormatter.string(from: self)
    }
}

#Preview {
    NavigationStack{
        MainView()
    }
    .colorScheme(.dark)
}

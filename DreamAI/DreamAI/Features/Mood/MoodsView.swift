//
// MoodsView.swift
//
// Created by Cesare on 08.07.2025 on Earth.
//


import SwiftUI

struct MoodsView: View {
    
    @StateObject private var viewModel = MoodsViewModel()
    @EnvironmentObject private var subscriptionViewModel: SubscriptionViewModel
    @Binding var selectedMood: Mood?
    var onAddAction: ((Mood) -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerView
            ZStack {
                // Front side - Selection
                selectionView
                    .opacity(viewModel.moodCreationMode ? 0.0 : 1.0)
                    .rotation3DEffect(
                        .degrees(viewModel.moodCreationMode ? 180 : 0),
                        axis: (x: 1, y: 0, z: 0),
                        perspective: 0.6
                    )
                // Back side - Creation
                creationView
                    .opacity(viewModel.moodCreationMode ? 1.0 : 0.0)
                    .rotation3DEffect(
                        .degrees(viewModel.moodCreationMode ? 0 : -180),
                        axis: (x: 1, y: 0, z: 0),
                        perspective: 0.6
                    )
            }
            .animation(.easeInOut(duration: 0.6), value: viewModel.moodCreationMode)
            .clipped()
        }
    }
}

private extension MoodsView {
    var headerView: some View {
        Text("Mood before sleep")
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(Color.appWhite)
    }
    
    var selectionView: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.moods) { mood in
                        Button(action: {
                            if subscriptionViewModel.isSubscribed {
                                selectedMood = mood
                            } else {
                                subscriptionViewModel.showPaywall()
                            }
                        }) {
                            VStack {
                                Text(mood.emoji)
                                    .font(.system(size: 28))
                                    .padding(10)
                                    .frame(width: 46, height: 46)
                                    .background(selectedMood == mood ?  Color.appPurple : Color.appGray7.opacity(0.35))
                                    .clipShape(.circle)
                                
                                Text(mood.title)
                                    .font(.caption2)
                                    .foregroundStyle(Color.appWhite)
                            }
                            .id(mood.id)
                        }
                    }
                    moodCreationButton
                }
                .padding(.horizontal, 16)
                .frame(height: 100)
            }
            .background(Color.appGray3)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .onChange(of: selectedMood?.id) { id in
                guard let id else { return }
                withAnimation {
                    scrollProxy.scrollTo(id, anchor: .center)
                }
            }
        }
    }
    
    var creationView: some View {
        HStack(spacing: 12) {
            HStack(spacing: 20) {
                TextField("Emoji", text: $viewModel.creatingMoodEmoji)
                    .frame(width: 44)
                TextField("Mood", text: $viewModel.creatingMoodTitle)
                    .frame(width: 44)
            }
            Spacer()
            VStack(spacing: 20) {
                Button {
                    viewModel.disableAndRestoreMoodCreation()
                } label: {
                    Image(.xMarkCircled)
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                Button {
                    guard let mood = viewModel.createMood() else {
                        return
                    }
                    onAddAction?(mood)
                } label: {
                    Text("Add")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color.appPurple)
                }
            }
        }
        .padding(12)
        .frame(height: 100)
        .background(Color.appGray3)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    var moodCreationButton: some View {
        Button {
            viewModel.moodCreationMode = true
        } label: {
            VStack {
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Color.appPurple)
                    .frame(width: 46, height: 46)
                    .background(Color.appGray7.opacity(0.35))
                    .clipShape(.circle)
                
                Text("Custom")
                    .font(.caption2)
                    .foregroundStyle(Color.appWhite)
            }
        }
    }
}

#Preview {
    MoodsView(selectedMood: .constant(.happy))
        .environmentObject(SubscriptionViewModel())
        .padding(20)
}

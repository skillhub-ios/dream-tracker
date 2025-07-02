//
//  MainFloatingPanelView.swift
//  DreamAI
//
//  Created by Shaxzod on 11/06/25.
//

import SwiftUI
import CoreHaptics

struct MainFloatingPanelView: View {
    @EnvironmentObject private var viewModel: MainViewModel
        
    @State private var dreamlistmode: DreamListItemMode = .view
    @State private var selectedDreamIds: [UUID] = []
    @State private var hapticTrigger = false
    @State private var showCreateDreamView = false
    @State private var showDreamInterpretation = false
    @State private var selectedDream: Dream?
    
    var filteredDreams: [Dream] {
        viewModel.filterDreams()
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(Color.appGray4)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                SearchBarView(text: $viewModel.searchText, filter: $viewModel.searchBarFilter)
                    .padding(.top, 12)
                if filteredDreams.isEmpty {
                    EmptyStateCardView() {
                        showCreateDreamView = true
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(filteredDreams) { dream in
                                dreamRow(for: dream)
                            }
                        }
                        .padding(.top, 8)
                        .padding(.horizontal)
                        .padding(.bottom, 100)
                    }
                }
            }
            .padding(.top, 24)
            
            FloatingActionButton(mode: dreamlistmode) {
                if dreamlistmode == .edit {
//                    viewModel.deleteDreams(ids: selectedDreamIds)
                    selectedDreamIds.removeAll()
                    dreamlistmode = .view
                } else {
                    showCreateDreamView = true
                }
            }
            .padding(.bottom, 15)
        }
        .sheet(isPresented: $showCreateDreamView) {
            NavigationStack {
                CreateDreamView()
            }
            .presentationDetents([.large])
        }
//        .sheet(isPresented: $showDreamInterpretation) {
//            DreamInterpretationView(
//                viewModel: DreamInterpretationViewModel(
//                    dream: selectedDream
//                )
//            )
//        }
        .sheet(item: $selectedDream) {
            DreamInterpretationView(dream: $0)
        }
    }
}

// MARK: - Privat methods:
private extension MainFloatingPanelView {
    func dreamRow(for dream: Dream) -> some View {
        DreamListItemView(
            dream: dream,
            isSelected: selectedDreamIds.contains(dream.id),
            mode: dreamlistmode,
            requestStatus: dream.requestStatus
        )
        .scaleEffect(selectedDreamIds.contains(dream.id) ? 0.95 : 1.0)
        .onTapGesture {
            if dreamlistmode == .edit {
                toggleDreamSelection(dream: dream)
            } else {
                // Show dream interpretation
                selectedDream = dream
                showDreamInterpretation = true
            }
        }
        .onLongPressGesture {
            hapticTrigger.toggle()
            dreamlistmode = dreamlistmode == .edit ? .view : .edit
            toggleDreamSelection(dream: dream)
            if dreamlistmode == .view {
                selectedDreamIds.removeAll()
            }
        }
        .sensoryFeedback(.impact(weight: .heavy, intensity: 0.9), trigger: hapticTrigger )
    }
    
    func toggleDreamSelection(dream: Dream) {
        withAnimation(.easeInOut(duration: 0.1)) {
            if selectedDreamIds.contains(dream.id) {
                selectedDreamIds.removeAll { $0 == dream.id }
            } else {
                selectedDreamIds.append(dream.id)
            }
        }
    }
}

#Preview {
    MainFloatingPanelView()
        .environmentObject(MainViewModel())
}

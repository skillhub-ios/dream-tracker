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
    @EnvironmentObject private var subscriptionViewModel: SubscriptionViewModel
    @State private var dreamlistmode: DreamListItemMode = .view
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
                withAnimation {
                    if dreamlistmode == .edit {
                        viewModel.deleteSelectedDreams()
                        dreamlistmode = .view
                    } else {
                        showCreateDreamView = true
                    }
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
        .sheet(item: $selectedDream) { dream in
            if subscriptionViewModel.isSubscribed {
                DreamInterpretationView(dream: dream)
            } else {
                NavigationStack {
                    EditDreamView(dream: dream)
                }
                .presentationDetents([.large])
            }
        }
    }
}

// MARK: - Privat methods:
private extension MainFloatingPanelView {
    func dreamRow(for dream: Dream) -> some View {
        DreamListItemView(
            dream: dream,
            isSelected: viewModel.selectedDreamIds.contains(dream.id),
            mode: dreamlistmode,
            requestStatus: interpretationState(for: dream.id)
        )
        .scaleEffect(viewModel.selectedDreamIds.contains(dream.id) ? 0.95 : 1.0)
        .onTapGesture {
            if dreamlistmode == .edit {
                withAnimation {
                    viewModel.toggleDreamSelection(dreamId: dream.id)
                }
            } else {
                // Show dream interpretation
                selectedDream = dream
                showDreamInterpretation = true
            }
        }
        .onLongPressGesture {
            hapticTrigger.toggle()
            withAnimation {
                dreamlistmode = dreamlistmode == .edit ? .view : .edit
                viewModel.toggleDreamSelection(dreamId: dream.id)
                if dreamlistmode == .view {
                    viewModel.selectedDreamIds.removeAll()
                }
            }
        }
        .sensoryFeedback(.impact(weight: .heavy, intensity: 0.9), trigger: hapticTrigger )
    }
    
    func interpretationState(for id: UUID) -> RequestStatus {
        guard let loadingState = viewModel.loadingStatesByDreamId[id] else { return .idle }
        switch loadingState {
        case .success: return .success
        case .loading: return .loading(progress: 0.5)
        case .error: return .error
        }
    }
}

#Preview {
    MainFloatingPanelView()
        .environmentObject(MainViewModel())
}

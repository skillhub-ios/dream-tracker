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
    @Binding var isBlured: Bool
    @State private var isDeletionAlertPresented: Bool = false
    
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
                    List {
                        ForEach(filteredDreams) { dream in
                            dreamRow(for: dream)
                                .listRowSeparator(.hidden)
                                .blur(radius: isBlured ? 12 : 0)
                                .applyIf(dreamlistmode == .view) {
                                    $0.swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            isDeletionAlertPresented = true
                                            viewModel.deletionDreamId = dream.id
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                    .swipeActions(edge: .leading) {
                                        Button() {
                                            showCreateDreamView = true
                                        } label: {
                                            Label("Add", systemImage: "plus")
                                                .tint(.appPurple)
                                        }
                                    }
                                }
                        }
                        Rectangle()
                            .frame(height: 100)
                            .opacity(0)
                            .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
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
        .alert(
            "Are you sure you want to delete this dream?",
            isPresented: $isDeletionAlertPresented
        ) {
            Button("Delete", role: .destructive) {
                guard let id = viewModel.deletionDreamId else {
                    isDeletionAlertPresented = false
                    return }
                isDeletionAlertPresented = false
                withAnimation {
                    viewModel.deleteDreamBy(id: id)
                }
            }
            Button("Cancel", role: .cancel) {
                isDeletionAlertPresented = false
                viewModel.deletionDreamId = nil
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
    MainFloatingPanelView(isBlured: .constant(false))
        .environmentObject(MainViewModel())
}

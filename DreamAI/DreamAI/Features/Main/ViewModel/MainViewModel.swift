//
//  MainViewModel.swift
//  DreamAI
//
//  Created by Shaxzod on 11/06/25.
//

import SwiftUI
import Combine

final class MainViewModel: ObservableObject {
    
    // MARK: - Public Properties
    
    @Published var searchBarFilter: SearchBarFilter = .newestFirst
    @Published var searchText: String = ""
    @Published var lastDream: Dream?
    @Published var dreams: [Dream] = []
    @Published var dreamInterpretations: [Interpretation] = []
    @Published var selectedDreamIds: [UUID] = []
    @Published var loadingStatesByDreamId: [UUID: ContentStateType] = [:]
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - External Dependencies
    
    private let coreDataStore = DIContainer.coreDataStore
    
    // MARK: - Lifecycle
    
    init() {
        addSubscriptions()
    }
    
    // MARK: - Public Functions
    
    public func deleteSelectedDreams() {
        dreams.removeAll { selectedDreamIds.contains($0.id) }
        coreDataStore.deleteDreamsAndItsInterpretations(dreamsIds: selectedDreamIds)
        selectedDreamIds.removeAll()
    }
    
    func toggleDreamSelection(dreamId: UUID) {
        if selectedDreamIds.contains(dreamId) {
            selectedDreamIds.removeAll { $0 == dreamId }
        } else {
            selectedDreamIds.append(dreamId)
        }
    }
    
    // MARK: - Private Functions
    
    private func addSubscriptions() {
        NotificationCenter.default.publisher(for: Notification.Name(PublisherKey.addDream.rawValue))
            .compactMap { extractValue(from: $0, as: Dream.self) }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] dream in
                guard let self = self else { return }
                dreams.insert(dream, at: 0)
                coreDataStore.saveDream(dream)
            }
            .store(in: &cancellables)
        
        coreDataStore.$dreams
            .dropIfEmpty()
            .map(fromEntitiesToSortedDreams)
            .receive(on: DispatchQueue.main)
            .assign(to: &$dreams)
        
        $dreams
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] dreams in
                self?.lastDream = dreams.first
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: Notification.Name(PublisherKey.changeDream.rawValue))
            .compactMap { extractValue(from: $0, as: Dream.self) }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedDream in
                guard let self = self else { return }
                if let index = dreams.firstIndex(where: { $0.id == updatedDream.id }) {
                    self.dreams[index] = updatedDream
                    self.coreDataStore.updateDream(updatedDream)
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: Notification.Name(PublisherKey.interpretationLoadingStatus.rawValue))
            .compactMap { extractValue(from: $0, as: [UUID: ContentStateType].self) }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] dictionary in
                guard let self = self else { return }
                for (id, state) in dictionary {
                    self.loadingStatesByDreamId[id] = state
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: Notification.Name(PublisherKey.updateTags.rawValue))
            .compactMap { extractValue(from: $0, as: [UUID: [String]].self) }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tagsById in
                guard let self = self else { return }
                for (id, tags) in tagsById {
                    if let index = self.dreams.firstIndex(where: { $0.id == id }) {
                        self.dreams[index].updateTags(tags)
                        let updatedDream = self.dreams[index]
                        self.coreDataStore.updateDream(updatedDream)
                    }
                }
                
            }
            .store(in: &cancellables)
    }
    
    private func fromEntitiesToSortedDreams(_ entities: [DreamEntity]) -> [Dream] {
        entities
            .map { Dream(from: $0) }
            .sorted(by: { $0.date > $1.date })
    }
    
    
    // MARK: - OLD ---------------------------------
    
    func filterDreams() -> [Dream] {
        let sortedDreams = filterBySearchBarFilter()
        if searchText.isEmpty { return sortedDreams }
        return sortedDreams.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.tags.contains(where: { $0.rawValue.localizedCaseInsensitiveContains(searchText) }) }
    }
    
    func filterBySearchBarFilter() -> [Dream] {
        switch searchBarFilter {
        case .newestFirst:
            return dreams.sorted(by: { $0.date > $1.date })
        case .oldestFirst:
            return dreams.sorted(by: { $0.date < $1.date })
        case .tags:
            return dreams.sorted(by: { $0.tags.count > $1.tags.count })
        case .moods:
            return dreams.sorted(by: { $0.tags.count > $1.tags.count })
        }
    }
}

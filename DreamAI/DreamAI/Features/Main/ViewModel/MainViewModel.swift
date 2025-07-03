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
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - External Dependencies
    
    private let coreDataStore = DIContainer.coreDataStore
    
    // MARK: - Lifecycle
    
    init() {
        addSubscriptions()
    }
    
    // MARK: - Public Functions
    
    // MARK: - Private Functions
    
    private func addSubscriptions() {
        NotificationCenter.default.publisher(for: Notification.Name(PublisherKey.addDream.rawValue))
            .compactMap { extractValue(from: $0, as: Dream.self) }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] dream in
                guard let self = self else { return }
                self.dreams.insert(dream, at: 0)
                self.coreDataStore.saveDream(dream)
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
    
    //    func deleteDreams(ids: [UUID]) {
    //        dreamManager.deleteDreams(ids: ids)
    //    }
    //
    //    func addDream(_ dream: Dream) {
    //        dreamManager.addDream(dream)
    //    }
    //
    //    func startDreamInterpretation(dreamId: UUID) {
    //        dreamManager.startDreamInterpretation(dreamId: dreamId)
    //    }
}

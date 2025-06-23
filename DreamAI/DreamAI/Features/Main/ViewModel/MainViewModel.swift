//
//  MainViewModel.swift
//  DreamAI
//
//  Created by Shaxzod on 11/06/25.
//

import SwiftUI
import Combine

@MainActor
class MainViewModel: ObservableObject {
    @Published var searchBarFilter: SearchBarFilter = .newestFirst
    @Published var searchText: String = ""
    @Published var lastDream: Dream?
    
    private var cancellables = Set<AnyCancellable>()
    private let dreamManager = DreamManager.shared
    
    var dreams: [Dream] {
        dreamManager.dreams
    }
    
    init() {
        // Subscribe to dreamManager's changes
        dreamManager.$dreams
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
                self?.lastDream = self?.dreamManager.dreams.first
            }
            .store(in: &cancellables)
        
        self.lastDream = dreamManager.dreams.first
        
        $searchBarFilter
            .sink { _ in
                self.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

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

    func deleteDreams(ids: [UUID]) {
        dreamManager.deleteDreams(ids: ids)
    }
    
    func addDream(_ dream: Dream) {
        dreamManager.addDream(dream)
    }
    
    func startDreamInterpretation(dreamId: UUID) {
        dreamManager.startDreamInterpretation(dreamId: dreamId)
    }
}

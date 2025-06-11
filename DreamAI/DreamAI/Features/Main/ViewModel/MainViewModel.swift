//
//  MainViewModel.swift
//  DreamAI
//
//  Created by Shaxzod on 11/06/25.
//

import SwiftUI

class MainViewModel: ObservableObject {
    @Published var searchBarFilter: SearchBarFilter = .newestFirst
    @Published var searchText: String = ""
    @Published var dreams: [Dream] = []
    @Published var lastDream: Dream?

    init() {
        self.dreams = [
            Dream(
                emoji: "😰",
                emojiBackground: .appGreen,
                title: "Falling from a great height",
                tags: [.nightmare, .epicDream],
                date: Date(timeIntervalSinceNow: -100000)
            ),
            Dream(
                emoji: "🏃‍♂️",
                emojiBackground: .appBlue,
                title: "Running but can't escape",
                tags: [.nightmare, .epicDream, .continuousDream, .propheticDream],
                date: Date()
            ),
            Dream(
                emoji: "☁️",
                emojiBackground: .appRed,
                title: "Flying over the city",
                tags: [.nightmare, .epicDream, .continuousDream],
                date: Date()
            )
        ]
        self.lastDream = dreams.first
    }

    func filterDreams() -> [Dream] {
        if searchText.isEmpty { return dreams }
        return dreams.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.tags.contains(where: { $0.rawValue.localizedCaseInsensitiveContains(searchText) }) }
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
        dreams = dreams.filter { !ids.contains($0.id) }
    }
}

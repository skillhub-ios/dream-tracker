//
//  DreamListItemView.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

enum DreamListItemMode {
    case edit
    case view
}

struct DreamListItemView: View {
    let dream: Dream
    let isSelected: Bool
    let mode: DreamListItemMode
    let requestStatus: RequestStatus
    
    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(dream.emojiBackground)
                    .frame(width: 48, height: 48)
                Text(dream.emoji)
                    .font(.system(size: 28))
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(dream.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2)
                HStack(spacing: 6) {
                    ForEach(dream.tags.prefix(2), id: \ .self) { tag in
                        Text(tag.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.appGray7.opacity(0.36))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                }
                if ![.idle, .success].contains(requestStatus) || mode == .edit {
                    dateUI
                }
            }
            .padding(.leading, 16)
            
            Spacer()
            
                if mode == .edit {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(Color.appPurple)
                        .font(.title2)
                        .frame(maxHeight: .infinity)
                        .background(isSelected ? .white : .appGray3)
                        .clipShape(Circle())
                } else {
                    stateUI(requestStatus)
                }
        }
        .padding()
        .frame(maxHeight: 110)
        .background(Color.appGray3)
        .cornerRadius(18)
    }
}

private extension DreamListItemView {
    var dateUI: some View {
        HStack(spacing: 4) {
            Text(dream.date.dateTimeWithSeparator)
                .font(.footnote)
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
        }
    }

    var dateVerticalUI: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(dream.date.formattedWithSpace())
                .font(.footnote)
                .foregroundColor(.gray)
                .multilineTextAlignment(.trailing)
        }
    }
    
    func stateUI(_ state: RequestStatus) -> some View {
        ZStack {
            switch state {
            case .idle where mode != .edit, .success where mode != .edit :
                dateVerticalUI
            case .loading: 
                MagicLoadingUI()
                    .frame(width: 26, height: 26)
            case .error:
                Image(systemName: "exclamationmark.circle")
                .resizable()
                .scaledToFill()
                .foregroundColor(.appOrange)
                .frame(width: 26, height: 26)
            case .success, .idle: EmptyView()
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        DreamListItemView(dream: Dream(emoji: "😰", emojiBackground: .appGreen, title: "Falling from a great height", tags: [.nightmare, .epicDream], date: Date()), isSelected: false, mode: .view, requestStatus: .idle)
        DreamListItemView(dream: Dream(emoji: "🏃‍♂️", emojiBackground: .appBlue, title: "Running but can't escape", tags: [.nightmare, .epicDream, .continuousDream, .propheticDream], date: Date()), isSelected: true, mode: .edit, requestStatus: .loading(progress: 0.5))
        DreamListItemView(dream: Dream(emoji: "🏃‍♂️", emojiBackground: .appRed, title: "Running but can't escape", tags: [.nightmare, .epicDream, .continuousDream], date: Date()), isSelected: false, mode: .edit, requestStatus: .success)
        DreamListItemView(dream: Dream(emoji: "🏃‍♂️", emojiBackground: .appOrange, title: "Running but can't escape", tags: [.nightmare, .epicDream, .continuousDream], date: Date()), isSelected: false, mode: .view, requestStatus: .error)
    }
    .padding()
    .background(Color.black)
}

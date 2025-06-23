//
//  SearchBarView.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    @Binding var filter: SearchBarFilter
    
    
    var body: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("", text: $text, prompt: Text("Search").foregroundColor(.gray))
                    .foregroundColor(.primary)
            }
            .padding(10)
            .frame(height: 40)
            .background(Color.appGray8.opacity(0.24))
            .cornerRadius(10)
            
            Menu {
                ForEach(SearchBarFilter.allCases, id: \.self) { filter in
                    Button(action: { self.filter = filter }) {
                        if filter == self.filter {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.white)
                                    .font(.system(size: 12))
                                    .fontWeight(.semibold)
                                
                                Label(filter.rawValue, systemImage: filter.systemImage)
                            }
                        } else {
                            Label(filter.rawValue, systemImage: filter.systemImage)
                        }
                    }
                }
            } label: {
                Label("Filter", systemImage: "line.3.horizontal.decrease")
                    .labelStyle(.iconOnly)
                    .foregroundStyle(Color.gray)
                    .padding(10)
                    .frame(height: 40)
                    .background(Color.appGray8.opacity(0.24))
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    StatefulPreviewWrapper("") { AnyView(SearchBarView(text: $0, filter: .constant(.tags))) }
}

// Helper for previewing @Binding
struct StatefulPreviewWrapper<Value>: View {
    @State var value: Value
    var content: (Binding<Value>) -> AnyView
    init(_ value: Value, content: @escaping (Binding<Value>) -> AnyView) {
        _value = State(initialValue: value)
        self.content = content
    }
    var body: some View {
        content($value)
    }
}

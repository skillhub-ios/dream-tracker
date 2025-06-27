//
// SubscriptionSegmentPicker.swift
//
// Created by Cesare on 26.06.2025 on Earth.
// 


import SwiftUI

struct SubscriptionSegmentPicker<SelectionValue, Content>: View where SelectionValue: Hashable, Content: View {
    
    @Binding var selection: SelectionValue
    @Namespace var namespace
    private let content: Content
    
    init(
        selection: Binding<SelectionValue>,
        @ViewBuilder content: () -> Content
    ) {
        self._selection = selection
        self.content = content()
    }
    
    var body: some View {
        HStack(spacing: .zero) {
            content
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .frame(height: 82)
        .padding(.horizontal, 12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.appPurpleGrayBackground))
        .environment(\.selectedSegmentTag, $selection)
        .environment(\.segmentedControlNamespace, namespace)
    }
}

private struct SelectedSegmentTagKey: EnvironmentKey {
    static var defaultValue: Any?
}

struct SegmentedControlItemContainer<SelectionValue, Content>: View where SelectionValue: Hashable, Content: View {
    
    @Environment(\.selectedSegmentTag) var selectedSegmentTag
    @Environment(\.segmentedControlNamespace) var segmentedControlNamespace
    @Namespace var namespace
    let tag: SelectionValue
    let content: Content
    let disabled: Bool
    
    var body: some View {
        content
            .frame(maxWidth: .infinity)
            .frame(height: 66)
            .contentShape(Rectangle())
            .foregroundColor(disabled ? .blue : .yellow)
            .background(isSelected ? background : nil)
            .onTapGesture {
                if !disabled {
                    select()
                }
            }
            .disabled(isSelected)
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.appPurpleDarkStroke)
            .matchedGeometryEffect(
                id: "selection",
                in: segmentedControlNamespace ?? namespace)
    }
    
    private var isSelected: Bool {
        let selectedTag = (selectedSegmentTag as? Binding<SelectionValue>)?.wrappedValue
        return tag == selectedTag
    }
    
    private func select() {
        withAnimation(.easeInOut(duration: 0.2)) {
            if let binding = selectedSegmentTag as? Binding<SelectionValue> {
                binding.wrappedValue = tag
            }
        }
    }
}

private struct SegmentedControlNamespaceKey: EnvironmentKey {
    static var defaultValue: Namespace.ID?
}

private extension EnvironmentValues {
    var segmentedControlNamespace: Namespace.ID? {
        get { self[SegmentedControlNamespaceKey.self] }
        set { self[SegmentedControlNamespaceKey.self] = newValue }
    }
}

struct CustomSegmentPicker_Previews: PreviewProvider {
    struct ContainerView: View {
        @State private var subscriptionType: SubscriptionType = .monthly
        var body: some View {
            SubscriptionSegmentPicker(selection: $subscriptionType) {
                ForEach(SubscriptionType.allCases) { type in
                    Text(type.title)
                        .font(.callout)
                        .foregroundStyle(.white)
                        .segmentedControlItemTag(type)
                }
            }
        }
    }
    
    static var previews: some View {
        ContainerView()
            .padding(20)
    }
}

private extension EnvironmentValues {
    var selectedSegmentTag: Any? {
        get { self[SelectedSegmentTagKey.self] }
        set { self[SelectedSegmentTagKey.self] = newValue }
    }
}

extension View {
    func segmentedControlItemTag<SelectionValue: Hashable>(_ tag: SelectionValue, disabled: Bool = false) -> some View {
        SegmentedControlItemContainer(tag: tag, content: self, disabled: disabled)
    }
}

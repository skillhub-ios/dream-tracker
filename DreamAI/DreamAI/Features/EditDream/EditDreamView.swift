//
// EditDreamView.swift
//
// Created by Cesare on 04.07.2025 on Earth.
//


import SwiftUI

struct EditDreamView: View {
    
    @StateObject private var editDreamViewModel: EditDreamViewModel
    @EnvironmentObject private var subscriptionViewModel: SubscriptionViewModel
    @State private var isShowingInterpretation: Bool = false
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isInputActive: Bool
    
    private var dateBinding: Binding<Date> {
        .init(
            get: { editDreamViewModel.dream.date },
            set: { editDreamViewModel.dream.date = $0 }
        )
    }
    
    private var descriptionBinding: Binding<String> {
        .init(
            get: { editDreamViewModel.dream.description },
            set: { editDreamViewModel.dream.description = $0 }
        )
    }
    
    init(dream: Dream) {
        self._editDreamViewModel = StateObject(wrappedValue: EditDreamViewModel(dream: dream))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appGray4
                    .ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 12) {
                        DreamDateView(date: dateBinding, isCreating: false)
                        dreamTextEditor(descriptionBinding)
                        MoodsView(selectedMood: $editDreamViewModel.mood) { mood in
                            editDreamViewModel.mood = mood
                        }
                        Spacer()
                        DButton(title: "Interpret Dream") {
                            if subscriptionViewModel.isSubscribed {
                                editDreamViewModel.saveDream()
                                isShowingInterpretation = true
                                editDreamViewModel.analitics.log(
                                    .premiumFeatureUsed(
                                        feature: PremiumFeature.interpretDream,
                                        screen: ScreenName.editDream))
                            } else {
                                subscriptionViewModel.showPaywall()
                            }
                        }
                    }
                    .padding([.horizontal, .bottom], 16)
                }
            }
            .navigationTitle("Dream Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    cancelNavigationButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    doneNavigationButton()
                }
            }
            .onChange(of: isShowingInterpretation) {
                if !isShowingInterpretation {
                    dismiss()
                }
            }
            .sheet(isPresented: $isShowingInterpretation) {
                DreamInterpretationView(dream: editDreamViewModel.dream)
            }
            .gesture(
                DragGesture(minimumDistance: 20, coordinateSpace: .local)
                    .onEnded { value in
                        if value.translation.height > 20 {
                            isInputActive = false
                        }
                    }
            )
        }
        .logScreenView(ScreenName.editDream)
        .onChange(of: editDreamViewModel.mood) { oldValue, newValue in
            if oldValue == nil && newValue != nil {
                editDreamViewModel.analitics.log(.premiumFeatureUsed(
                    feature: PremiumFeature.selectMood,
                    screen: ScreenName.editDream))
            }
        }
    }
}

private extension EditDreamView {
    func dreamTextEditor(_ dreamText: Binding<String>) -> some View {
        ZStack(alignment: .topLeading) {
            if dreamText.wrappedValue.isEmpty {
                Text("I dreamed...")
                    .font(.system(size: 17))
                    .foregroundStyle(Color.gray)
                    .padding(.top, 10)
                    .padding(.leading, 5)
            }
            
            TextEditor(text: dreamText)
                .font(.system(size: 17))
                .focused($isInputActive)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        
                        Button("Done") {
                            isInputActive = false
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .foregroundStyle(Color.appWhite)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .frame(height: SCREEN_HEIGHT * 0.3)
        .background(Color.appGray3)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    func moodPicker(_ selectedMood: Binding<Mood?>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mood before sleep")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.appWhite)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Mood.predefined) { mood in
                        Button(action: {
                            withAnimation {
                                selectedMood.wrappedValue = mood
                            }
                        }) {
                            VStack {
                                Text(mood.emoji)
                                    .font(.system(size: 28))
                                    .padding(10)
                                    .background(selectedMood.wrappedValue == mood ?  Color.appPurple : Color.appGray7.opacity(0.35))
                                    .clipShape(.circle)
                                Text(mood.title)
                                    .font(.caption2)
                                    .foregroundStyle(Color.appWhite)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
            }
            .background(Color.appGray1)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    func cancelNavigationButton() -> some View {
        Button(action: {
            dismiss()
        }) {
            Text("Cancel")
                .foregroundColor(.appPurple)
        }
    }
    
    func doneNavigationButton() -> some View {
        Button(action: {
            editDreamViewModel.saveDream()
            dismiss()
        }) {
            Text("Done")
                .foregroundColor(.appPurple)
        }
    }
}

#Preview {
    EditDreamView(dream: loadMockDreams().first!)
        .environmentObject(SubscriptionViewModel())
}

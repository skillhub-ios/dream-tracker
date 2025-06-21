//
//  ExportImportView.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

struct ExportImportView: View {
    @StateObject private var viewModel = ExportImportViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.appGray4.ignoresSafeArea()
            
            VStack(spacing: 12) {
                
                // Description
                description
                
                List {
                    // Icon
                    Section {
                        icon
                    }
                    // Action Buttons
                    if viewModel.currentState == .initial {
                        Section {
                            exportButton
                            importButton
                        }
                    }
                }
                .listSectionSpacing(12)
                
                // Bottom Action Button
                bottomActionButton
                    .padding(.horizontal, 24)
            }
        }
        .navigationTitle("Export/Import")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.appPurple)
            }
        }
    }
}

// MARK: - Private Views

private extension ExportImportView {
    
    var description: some View {
        Text("Export or import a file from your phone to restore data")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(16)
    }
    
    var icon: some View {
        ZStack {
            Circle()
                .fill(Color.appPurple)
                .frame(width: 120, height: 120)
            
            Image(systemName: "link")
                .font(.system(size: 48, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(height: 154)
    }
    
    var exportButton: some View {
        Button(action: {
            viewModel.startExport()
        }) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                    .font(.title3)
                    .foregroundColor(.appPurple)
                
                Text("Export")
                    .font(.body)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    var importButton: some View {
        Button(action: {
            viewModel.startImport()
        }) {
            HStack {
                Image(systemName: "square.and.arrow.down")
                    .font(.title3)
                    .foregroundColor(.appPurple)
                
                Text("Import")
                    .font(.body)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    var bottomActionButton: some View {
        switch viewModel.currentState {
        case .initial:
            EmptyView()
        case .loading:
            Button(action: {}) {
                HStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                    
                    Text("Load...")
                        .font(.body)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.3))
                .clipShape(.capsule)
            }
            .disabled(true)
        case .done:
            Button(action: {
                dismiss()
            }) {
                Text("Done")
                    .font(.body)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.appPurple)
                    .clipShape(.capsule)
            }
        case .error:
            Button(action: {
                viewModel.resetToInitial()
            }) {
                Text("Error (Incorrect file)")
                    .font(.body)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.red.opacity(0.8))
                    .clipShape(.capsule)
            }
        }
    }
}

#Preview {
    ZStack {
        Text("ImportView")
    }
    .sheet(isPresented: .constant(true)) {
        NavigationStack {
            ExportImportView()
        }
    }
}

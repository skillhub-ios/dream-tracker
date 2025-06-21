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
    
    @State private var showingDocumentPicker = false
    @State private var showingShareSheet = false
    @State private var showingBackupFiles = false
    @State private var showingDebugInfo = false
    
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
                            backupFilesButton
                            debugButton
                        }
                    }
                    
                    // Progress Section
                    if viewModel.currentState == .loading {
                        Section {
                            progressSection
                        }
                    }
                    
                    // Error Section
                    if viewModel.currentState == .error {
                        Section {
                            errorSection
                        }
                    }
                    
                    // Success Section
                    if viewModel.currentState == .done {
                        Section {
                            successSection
                        }
                    }
                }
                .listSectionSpacing(12)
                
                // Bottom Action Button
                bottomActionButton
                    .padding(.horizontal, 24)
            }
        }
        .navigationTitle("Backup & Restore")
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
        .sheet(isPresented: $showingDocumentPicker) {
            DocumentPickerHelper(
                onFileSelected: { url in
                    viewModel.importFromFile(url)
                },
                onCancelled: {
                    viewModel.resetToInitial()
                }
            )
        }
        .sheet(isPresented: $showingShareSheet) {
            if let fileURL = viewModel.exportImportManager.exportedFileURL {
                FileExportHelper(
                    fileURL: fileURL,
                    onExported: {
                        viewModel.successMessage = "Dreams shared successfully"
                    },
                    onCancelled: {
                        viewModel.successMessage = "Share cancelled"
                    }
                )
            }
        }
        .sheet(isPresented: $showingBackupFiles) {
            BackupFilesListView()
        }
        .sheet(isPresented: $showingDebugInfo) {
            DebugFileInfoView()
        }
        .onReceive(viewModel.$successMessage) { message in
            if message != nil {
                // Handle success message
            }
        }
        .onReceive(viewModel.$errorMessage) { message in
            if message != nil {
                // Handle error message
            }
        }
        .onReceive(viewModel.exportImportManager.$exportedFileURL) { fileURL in
            if fileURL != nil && viewModel.currentState == .done {
                // Don't automatically show share sheet - let user decide
                print("✅ File exported successfully: \(fileURL?.path ?? "unknown")")
            }
        }
    }
}

// MARK: - Private Views

private extension ExportImportView {
    
    var description: some View {
        Text("Export or import a file from your phone to backup and restore your dreams")
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
            
            Image(systemName: "icloud.and.arrow.up")
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
                
                Text("Export Dreams")
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
            showingDocumentPicker = true
        }) {
            HStack {
                Image(systemName: "square.and.arrow.down")
                    .font(.title3)
                    .foregroundColor(.appPurple)
                
                Text("Import Dreams")
                    .font(.body)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    var backupFilesButton: some View {
        Button(action: {
            showingBackupFiles = true
        }) {
            HStack {
                Image(systemName: "folder")
                    .font(.title3)
                    .foregroundColor(.appPurple)
                
                Text("Backup Files")
                    .font(.body)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    var debugButton: some View {
        Button(action: {
            showingDebugInfo = true
        }) {
            HStack {
                Image(systemName: "info.circle")
                    .font(.title3)
                    .foregroundColor(.appPurple)
                
                Text("Debug Info")
                    .font(.body)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    var progressSection: some View {
        VStack(spacing: 12) {
            ProgressView(value: viewModel.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .appPurple))
            
            Text("Processing... \(Int(viewModel.progress * 100))%")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
    
    var errorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.appRed)
                Text("Error")
                    .font(.headline)
                    .foregroundColor(.appRed)
            }
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
    
    var successSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.appGreen)
                Text("Success")
                    .font(.headline)
                    .foregroundColor(.appGreen)
            }
            
            if let successMessage = viewModel.successMessage {
                Text(successMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
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
                    
                    Text("Processing...")
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
            VStack(spacing: 12) {
                Button(action: {
                    showingShareSheet = true
                }) {
                    Text("Share Export")
                        .font(.body)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.appBlue)
                        .clipShape(.capsule)
                }
                
                Button(action: {
                    viewModel.startExport()
                }) {
                    Text("New Export")
                        .font(.body)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.appGreen)
                        .clipShape(.capsule)
                }
                
                Button(action: {
                    viewModel.resetToInitial()
                }) {
                    Text("Done")
                        .font(.body)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.appPurple)
                        .clipShape(.capsule)
                }
            }
        case .error:
            Button(action: {
                viewModel.resetToInitial()
            }) {
                Text("Try Again")
                    .font(.body)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.appRed.opacity(0.8))
                    .clipShape(.capsule)
            }
        }
    }
}

// MARK: - Backup Files List View
struct BackupFilesListView: View {
    @State private var backupFiles: [BackupFileInfo] = []
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(backupFiles) { backupFile in
                    BackupFileRowView(backupFile: backupFile)
                }
                .onDelete(perform: deleteBackupFiles)
            }
            .navigationTitle("Backup Files")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear All") {
                        clearAllBackupFiles()
                    }
                    .foregroundColor(.appRed)
                }
            }
        }
        .onAppear {
            loadBackupFiles()
        }
    }
    
    private func loadBackupFiles() {
        let urls = FileManagerHelper.getBackupFiles()
        backupFiles = urls.map { BackupFileInfo(url: $0) }
    }
    
    private func deleteBackupFiles(offsets: IndexSet) {
        for index in offsets {
            let backupFile = backupFiles[index]
            do {
                try FileManagerHelper.deleteFile(at: backupFile.url)
            } catch {
                print("Failed to delete backup file: \(error)")
            }
        }
        loadBackupFiles()
    }
    
    private func clearAllBackupFiles() {
        for backupFile in backupFiles {
            do {
                try FileManagerHelper.deleteFile(at: backupFile.url)
            } catch {
                print("Failed to delete backup file: \(error)")
            }
        }
        loadBackupFiles()
    }
}

struct BackupFileRowView: View {
    let backupFile: BackupFileInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(backupFile.name)
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                Text(backupFile.formattedCreationDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(backupFile.formattedFileSize)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
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

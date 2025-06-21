//
//  DebugFileInfoView.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

struct DebugFileInfoView: View {
    @State private var filePathInfo: String = ""
    @State private var backupFiles: [BackupFile] = []
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // File Path Information
                    VStack(alignment: .leading, spacing: 12) {
                        Text("File Path Information")
                            .font(.headline)
                            .foregroundColor(.appPurple)
                        
                        Text(filePathInfo)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding()
                            .background(Color.appGray4)
                            .cornerRadius(8)
                    }
                    
                    // Backup Files
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Backup Files (\(backupFiles.count))")
                            .font(.headline)
                            .foregroundColor(.appPurple)
                        
                        if backupFiles.isEmpty {
                            Text("No backup files found")
                                .foregroundColor(.secondary)
                                .italic()
                        } else {
                            ForEach(backupFiles) { backupFile in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(backupFile.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Text("Path: \(backupFile.url.path)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    HStack {
                                        Text(backupFile.formattedCreationDate)
                                        Spacer()
                                        Text(backupFile.formattedFileSize)
                                    }
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color.appGray4)
                                .cornerRadius(8)
                            }
                        }
                    }
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How to Find Your Files")
                            .font(.headline)
                            .foregroundColor(.appPurple)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("1. Open the Files app on your iPhone")
                            Text("2. Tap 'On My iPhone' or 'On My iPad'")
                            Text("3. Look for a folder with your app name")
                            Text("4. Your backup files will be there")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                        .background(Color.appGray4)
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationTitle("File Debug Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadFileInfo()
        }
    }
    
    private func loadFileInfo() {
        let exportImportManager = ExportImportManager.shared
        
        // Get file path info
        filePathInfo = exportImportManager.getCurrentFilePathInfo()
        
        // Get backup files
        do {
            backupFiles = try exportImportManager.getBackupFiles()
        } catch {
            print("Failed to load backup files: \(error)")
        }
    }
}

#Preview {
    DebugFileInfoView()
} 
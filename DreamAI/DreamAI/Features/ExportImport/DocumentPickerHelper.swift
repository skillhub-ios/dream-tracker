//
//  DocumentPickerHelper.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI
import UniformTypeIdentifiers

struct DocumentPickerHelper: UIViewControllerRepresentable {
    let onFileSelected: (URL) -> Void
    let onCancelled: () -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.json])
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        picker.shouldShowFileExtensions = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onFileSelected: onFileSelected, onCancelled: onCancelled)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onFileSelected: (URL) -> Void
        let onCancelled: () -> Void
        
        init(onFileSelected: @escaping (URL) -> Void, onCancelled: @escaping () -> Void) {
            self.onFileSelected = onFileSelected
            self.onCancelled = onCancelled
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else {
                onCancelled()
                return
            }
            
            // Start accessing the security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                print("❌ Failed to access security-scoped resource: \(url.path)")
                onCancelled()
                return
            }
            
            // Call the completion handler
            onFileSelected(url)
            
            // Note: We don't stop accessing here because the file operations need to complete
            // The calling code should handle stopping access when done
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            onCancelled()
        }
    }
}

// MARK: - File Export Helper
struct FileExportHelper: UIViewControllerRepresentable {
    let fileURL: URL
    let onExported: () -> Void
    let onCancelled: () -> Void
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(
            activityItems: [fileURL],
            applicationActivities: nil
        )
        
        activityViewController.completionWithItemsHandler = { _, completed, _, _ in
            if completed {
                onExported()
            } else {
                onCancelled()
            }
        }
        
        return activityViewController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - File Manager Helper
struct FileManagerHelper {
    
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    static func getAccessibleDirectory() -> URL {
        // This will save to "On My iPhone" directory
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    static func getBackupFiles() -> [URL] {
        let accessiblePath = getAccessibleDirectory()
        
        do {
            let files = try FileManager.default.contentsOfDirectory(
                at: accessiblePath,
                includingPropertiesForKeys: [.creationDateKey, .fileSizeKey]
            )
            
            return files.filter { url in
                url.pathExtension == "json" && 
                url.lastPathComponent.contains("DreamAI_Backup")
            }.sorted { url1, url2 in
                let date1 = try? url1.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                let date2 = try? url2.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                return date1! > date2!
            }
        } catch {
            print("❌ Error reading backup files: \(error)")
            return []
        }
    }
    
    static func deleteFile(at url: URL) throws {
        try FileManager.default.removeItem(at: url)
        print("🗑️ Deleted file: \(url.lastPathComponent)")
    }
    
    static func getFileSize(for url: URL) -> Int64 {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.size] as? Int64 ?? 0
        } catch {
            print("❌ Error getting file size: \(error)")
            return 0
        }
    }
    
    static func getFileCreationDate(for url: URL) -> Date? {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.creationDate] as? Date
        } catch {
            print("❌ Error getting file creation date: \(error)")
            return nil
        }
    }
    
    static func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Backup File Model
struct BackupFileInfo: Identifiable {
    let id = UUID()
    let url: URL
    let name: String
    let creationDate: Date
    let fileSize: Int64
    
    var formattedFileSize: String {
        FileManagerHelper.formatFileSize(fileSize)
    }
    
    var formattedCreationDate: String {
        FileManagerHelper.formatDate(creationDate)
    }
    
    init(url: URL) {
        self.url = url
        self.name = url.lastPathComponent
        self.creationDate = FileManagerHelper.getFileCreationDate(for: url) ?? Date()
        self.fileSize = FileManagerHelper.getFileSize(for: url)
    }
} 
import Foundation
import SwiftUI

// MARK: - Date Extensions

extension Date {
    func formattedString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    func isToday() -> Bool {
        Calendar.current.isDateInToday(self)
    }
    
    func isYesterday() -> Bool {
        Calendar.current.isDateInYesterday(self)
    }
    
    func startOfDay() -> Date {
        Calendar.current.startOfDay(for: self)
    }
    
    func endOfDay() -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay()) ?? self
    }
}

// MARK: - String Extensions

extension String {
    func truncate(length: Int, trailing: String = "...") -> String {
        if self.count > length {
            return String(self.prefix(length)) + trailing
        } else {
            return self
        }
    }
    
    var isEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
}

// MARK: - View Extensions

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Array Extensions

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

// MARK: - Color Extensions

extension Color {
    static func random() -> Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}

// MARK: - Notification Extensions

extension Notification.Name {
    static let dreamDidUpdate = Notification.Name("dreamDidUpdate")
    static let settingsDidChange = Notification.Name("settingsDidChange")
    static let subscriptionStatusDidChange = Notification.Name("subscriptionStatusDidChange")
}

// MARK: - Error Extensions

extension Error {
    var localizedDescription: String {
        let error = self as NSError
        if error.domain == NSURLErrorDomain {
            switch error.code {
            case NSURLErrorNotConnectedToInternet:
                return "Нет подключения к интернету"
            case NSURLErrorTimedOut:
                return "Превышено время ожидания"
            case NSURLErrorCannotFindHost:
                return "Не удалось найти сервер"
            default:
                return "Произошла ошибка сети"
            }
        }
        return error.localizedDescription
    }
}

// MARK: - UserDefaults Extensions

extension UserDefaults {
    static var shared: UserDefaults {
        UserDefaults(suiteName: Constants.userDefaultsSuite) ?? .standard
    }
  }

// MARK: - FileManager Extensions

extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    static var backupDirectory: URL {
        documentsDirectory.appendingPathComponent("Backups")
    }
    
    func createBackupDirectoryIfNeeded() throws {
        if !fileExists(atPath: FileManager.backupDirectory.path) {
            try createDirectory(at: FileManager.backupDirectory, withIntermediateDirectories: true)
        }
    }
} 

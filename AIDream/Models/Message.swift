import Foundation

struct Message: Codable, Identifiable {
    let id = UUID()
    let role: Role
    let content: String
}

enum Role: String, Codable {
    case system
    case user
    case assistant
} 
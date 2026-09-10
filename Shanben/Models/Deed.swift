import Foundation
import SwiftData

@Model
final class Deed {
    var id: UUID
    var content: String
    var occurredAt: Date
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        content: String,
        occurredAt: Date = .now,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.content = content
        self.occurredAt = occurredAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct DeedDTO: Codable, Hashable {
    let id: UUID
    let content: String
    let occurredAt: Date
    let createdAt: Date
    let updatedAt: Date

    init(_ deed: Deed) {
        id = deed.id
        content = deed.content
        occurredAt = deed.occurredAt
        createdAt = deed.createdAt
        updatedAt = deed.updatedAt
    }
}

struct ShanbenBackup: Codable {
    let version: Int
    let exportedAt: Date
    let deeds: [DeedDTO]
}

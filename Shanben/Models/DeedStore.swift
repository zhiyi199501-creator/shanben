import Foundation

enum DeedStore {
    static func list(_ deeds: [Deed], on day: Date) -> [Deed] {
        let start = ShanbenCalendar.startOfDay(day)
        let end = ShanbenCalendar.endOfDay(day)
        return deeds
            .filter { $0.occurredAt >= start && $0.occurredAt < end }
            .sorted { $0.occurredAt > $1.occurredAt }
    }

    static func count(_ deeds: [Deed], from start: Date, to end: Date) -> Int {
        deeds.filter { $0.occurredAt >= start && $0.occurredAt < end }.count
    }

    static func countsByDay(_ deeds: [Deed], in month: Date) -> [Int: Int] {
        let start = ShanbenCalendar.startOfMonth(month)
        let end = ShanbenCalendar.endOfMonth(month)
        var counts: [Int: Int] = [:]
        for deed in deeds where deed.occurredAt >= start && deed.occurredAt < end {
            let day = ShanbenCalendar.calendar.component(.day, from: deed.occurredAt)
            counts[day, default: 0] += 1
        }
        return counts
    }

    static func backupJSON(from deeds: [Deed]) throws -> Data {
        let payload = ShanbenBackup(
            version: 1,
            exportedAt: .now,
            deeds: deeds
                .sorted { $0.occurredAt < $1.occurredAt }
                .map(DeedDTO.init)
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(payload)
    }
}

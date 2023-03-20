import Foundation

struct Tracker {
    let id: UUID
    let label: String
    let emoji: String
    let color: String
    let schedule: Set<WeekDay>?

    init(id: UUID = UUID(), label: String, emoji: String, color: String, schedule: Set<WeekDay>? ) {
        self.id = id
        self.label = label
        self.emoji = emoji
        self.color = color
        self.schedule = schedule

    }
}

extension Tracker {
    static func fromCoreData(_ data: TrackerCD, decoder: JSONDecoder) -> Tracker? {
        guard
            let id = data.id,
            let label = data.label,
            let emoji = data.emoji,
            let color = data.color
//            let hex = data.colorHex,
//            let color = TrackerColor(rawValue: hex)
        else { return nil }

        var schedule: Set<WeekDay>?
        if let scheduleData = data.schedule {
            schedule = try? decoder.decode(Set<WeekDay>.self, from: scheduleData)
        }

        return .init(id: id, label: label, emoji: emoji, color: color, schedule: schedule)
    }
}

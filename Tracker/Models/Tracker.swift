import Foundation

struct Tracker {
    let id: UUID
    let label: String
    let emoji: String
    let color: String
    let schedule: Set<WeekDay>?
    let isCompleted: Bool?
    let recordsCount: Int?
    let pinned: Bool
    
    init(id: UUID = UUID(), label: String, emoji: String, color: String, pinned: Bool, schedule: Set<WeekDay>?, isCompleted:Bool?, recordsCount: Int?) {
        self.id = id
        self.label = label
        self.emoji = emoji
        self.color = color
        self.pinned = pinned
        self.schedule = schedule
        self.isCompleted = isCompleted
        self.recordsCount = recordsCount
    }
}

extension Tracker {
    static func fromCoreData(_ data: TrackerCD, decoder: JSONDecoder, isCompleted: Bool?, recordsCount: Int?) -> Tracker? {
        guard
            let id = data.id,
            let label = data.label,
            let emoji = data.emoji,
            let color = data.color
        else { return nil }
        let pinned = data.pinned
        var schedule: Set<WeekDay>?
        if let scheduleData = data.schedule {
            schedule = try? decoder.decode(Set<WeekDay>.self, from: scheduleData)
        }
        
        
        return .init(id: id, label: label, emoji: emoji, color: color, pinned: pinned, schedule: schedule, isCompleted: isCompleted ?? false, recordsCount: recordsCount)
    }
}

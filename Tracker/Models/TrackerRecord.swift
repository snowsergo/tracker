import Foundation

struct TrackerRecord: Hashable {
    let id: UUID
    let trackerId: UUID
    let date: Date

    init(id: UUID = UUID(), trackerId: UUID, date: Date) {
        self.id = id
        self.trackerId = trackerId
        self.date = date
//        self.tracker = tracker
    }
}

extension TrackerRecord {
    static func fromCoreData(_ data: TrackerRecordCD)->TrackerRecord? {
        guard
            let id = data.id,
            let trackerId = data.tracker?.id,
            let date = data.date

        else { return nil }

        return .init(id: id, trackerId: trackerId, date: date)
    }
}

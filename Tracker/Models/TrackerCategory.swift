import Foundation

struct TrackerCategory {
    let id: UUID
    let label: String
    let trackers: [Tracker]

    init(id: UUID = UUID(), label: String, trackers: [Tracker]) {
        self.id = id
        self.label = label
        self.trackers = trackers
    }
}

extension TrackerCategory {
    static func fromCoreData(_ data: TrackerCategoryCD, decoder: JSONDecoder) -> TrackerCategory? {
        guard let id = data.id, let label = data.label else { return nil }

        let trackersCD = data.trackers as? Set<TrackerCD> ?? []
        let trackers = trackersCD.compactMap { Tracker.fromCoreData($0, decoder: decoder) }

        return .init(id: id, label: label, trackers: trackers)
    }
}

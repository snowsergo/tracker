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

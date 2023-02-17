import Foundation

struct Tracker {
    let id = UUID()
    let label: String
    let emoji: String
    let color: TrackerColor
    let schedule: Set<WeekDay>?
}

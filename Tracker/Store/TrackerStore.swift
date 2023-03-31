import UIKit

final class TrackerStore {
    var store: Store

    init(store: Store) {
        self.store = store
    }
    
    func addNewTracker(_ newTracker: Tracker, category: TrackerCategoryCD) {
        try? store.addNewTracker(newTracker, category: category)
    }

    func extractTrackerById(id: UUID) -> TrackerCD? {
        return store.extractTrackerById(id: id)
    }

    func extractAllTrackersAsArray() -> [Tracker]? {
        return store.extractAllTrackersAsArray()
    }
}

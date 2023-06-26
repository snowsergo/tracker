import UIKit

final class TrackerStore {
    var store: Store

    init(store: Store) {
        self.store = store
    }
    
    func addNewTracker(_ newTracker: Tracker, category: TrackerCategoryCD) {
        try? store.addNewTracker(newTracker, category: category)
    }

    func updateTracker(trackerCD: TrackerCD, newTracker: Tracker, category: TrackerCategoryCD)  {
        try? store.editTracker(trackerCD: trackerCD, newTracker: newTracker, category: category)
    }
    
    func deleteTracker(tracker: TrackerCD) throws {
        do {
            try store.deleteRecord(object: tracker)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }

    func togglePinned(tracker: TrackerCD) throws {
        do {
            let pinned = tracker.pinned
            tracker.pinned = !pinned
            try store.saveRecord(object: tracker)
        }
    }

    func extractTrackerById(id: UUID) -> TrackerCD? {
        return store.extractTrackerById(id: id)
    }

    func extractAllTrackersAsArray() -> [Tracker]? {
        return store.extractAllTrackersAsArray()
    }
}

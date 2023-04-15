import UIKit
import CoreData

final class TrackerRecordStore {
    var store: Store

    init(store:Store) {
        self.store = store
    }

    func addNewRecord(tracker: TrackerCD, date: Date) throws {
        try store.addNewRecord(tracker: tracker, date: date)
    }


    func deleteRecord(tracker: TrackerCD, date: Date) throws {
        try store.deleteRecord(tracker: tracker, date: date)
    }

    func extractAllRecordsAsArray() -> [TrackerRecord]  {
        store.extractAllRecordsAsArray()
    }

    func extractRecordByTrackerIdAndDate(id: UUID, date: Date) -> TrackerRecordCD? {
        store.extractRecordByTrackerIdAndDate(id: id, date: date)
    }
}


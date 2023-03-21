import UIKit
import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    private lazy var jsonEncoder = JSONEncoder()
    private lazy var jsonDecoder = JSONDecoder()
    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func addNewRecord(tracker: TrackerCD, date: Date) throws {
        let trackerRecordCoreData = TrackerRecordCD(context: context)
        updateExistingTrackerRecord(trackerRecordCoreData, tracker: tracker, date: date)
        try context.save()
    }

    func updateExistingTrackerRecord(_ trackerRecordCoreData: TrackerRecordCD,tracker: TrackerCD, date: Date) {
        trackerRecordCoreData.tracker = tracker
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        trackerRecordCoreData.date = startOfDay
        trackerRecordCoreData.id = UUID()
        trackerRecordCoreData.createdAt = Date()
    }

    func extractAllRecordsAsArray() -> [TrackerRecord] {
        let request = NSFetchRequest<TrackerRecordCD>(entityName: "TrackerRecordCD")
        let recordsCD = try! context.fetch(request)
        let records = recordsCD.compactMap { TrackerRecord.fromCoreData($0) }
        return records
    }
}


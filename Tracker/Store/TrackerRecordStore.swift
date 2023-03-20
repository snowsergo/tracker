import UIKit
import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
//    private let uiColorMarshalling = UIColorMarshalling()
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
//        guard let categoryCD = categoryStore.getById(id) else { return }
        let trackerRecordCoreData = TrackerRecordCD(context: context)
        updateExistingTrackerRecord(trackerRecordCoreData, tracker: tracker, date: date)
        try context.save()
        print("____CD____addTracker RECORD___2")
    }

    func updateExistingTrackerRecord(_ trackerRecordCoreData: TrackerRecordCD,tracker: TrackerCD, date: Date) {
        trackerRecordCoreData.tracker = tracker
        trackerRecordCoreData.date = date
        trackerRecordCoreData.id = UUID()
        trackerRecordCoreData.createdAt = Date()
    }

//    func extractTrackerById(id: UUID) -> TrackerCD? {
//        let request = NSFetchRequest<TrackerCD>(entityName: "TrackerCD")
//        request.predicate = NSPredicate(format: "%K == %@", "id", id as CVarArg)
//        request.fetchLimit = 1
//
//        return try? context.fetch(request).first
//    }
    func extractAllRecordsAsArray() -> [TrackerRecord] {
            let request = NSFetchRequest<TrackerRecordCD>(entityName: "TrackerRecordCD")
            let recordsCD = try! context.fetch(request)
//        print("====== = = = = = = = = categoties`cd = ", categoriesCD);
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"/
        let records = recordsCD.compactMap { TrackerRecord.fromCoreData($0) }
//        let date
        return records
    }

}

//func extractAllCategoriesAsArray() -> [TrackerCategory] {
//        let request = NSFetchRequest<TrackerCategoryCD>(entityName: "TrackerCategoryCD")
//        let categoriesCD = try! context.fetch(request)
////        print("====== = = = = = = = = categoties`cd = ", categoriesCD);
//    let categories = categoriesCD.compactMap { TrackerCategory.fromCoreData($0, decoder: jsonDecoder) }
////        categories.forEach { print("категория из бд \($0.label ?? "пустое слово")") }
//    return categories
//}

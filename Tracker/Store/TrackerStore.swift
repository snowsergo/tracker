import UIKit
import CoreData

final class TrackerStore {
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
    
    func addNewTracker(_ newTracker: Tracker, category: TrackerCategoryCD) throws {
        let TrackerCoreData = TrackerCD(context: context)
        updateExistingTracker(TrackerCoreData, with: newTracker, category: category)
        try context.save()
    }

    func updateExistingTracker(_ trackerCoreData: TrackerCD, with tracker: Tracker, category: TrackerCategoryCD) {
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = tracker.color
        trackerCoreData.label = tracker.label
        trackerCoreData.id = tracker.id
        trackerCoreData.createdAt = Date()
        trackerCoreData.category = category

        if let schedule = tracker.schedule {
            trackerCoreData.schedule = try? jsonEncoder.encode(schedule)
        }
    }
    func extractTrackerById(id: UUID) -> TrackerCD? {
        let request = NSFetchRequest<TrackerCD>(entityName: "TrackerCD")
        request.predicate = NSPredicate(format: "%K == %@", "id", id as CVarArg)
        request.fetchLimit = 1

        return try? context.fetch(request).first
    }

    func extractAllTrackersAsArray() -> [Tracker] {
        let request = NSFetchRequest<TrackerCD>(entityName: "TrackerCD")
        let trackersCD = try! context.fetch(request)
        let trackers = trackersCD.compactMap { Tracker.fromCoreData($0, decoder: jsonDecoder) }
        return trackers
    }
}

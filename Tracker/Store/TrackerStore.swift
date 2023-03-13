import UIKit
import CoreData

final class TrackerStore {
    private let context: NSManagedObjectContext
//    private let uiColorMarshalling = UIColorMarshalling()
    private lazy var jsonEncoder = JSONEncoder()
    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func addNewTracker(_ newTracker: Tracker) throws {
        let TrackerCoreData = TrackerCD(context: context)
        updateExistingTracker(TrackerCoreData, with: newTracker)
        try context.save()
        print("____CD____addTracker___2")
    }

    func updateExistingTracker(_ trackerCoreData: TrackerCD, with tracker: Tracker) {
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = tracker.color
        trackerCoreData.label = tracker.label
        trackerCoreData.id = UUID()
        trackerCoreData.createdAt = Date()

        if let schedule = tracker.schedule {
            trackerCoreData.schedule = try? jsonEncoder.encode(schedule)
        }
        print("____CD____addTracker___1")
    }

  
}

import UIKit
import CoreData

protocol StoreDelegate: AnyObject {
    func didUpdate()
}

final class Store: NSObject {
    private let context: NSManagedObjectContext
    weak var delegate: StoreDelegate?
    let calendar = Calendar.current
    
    var currentDate: Date = Date()
    var searchText: String = ""
    var isFiltered: Bool = false

    private lazy var jsonEncoder = JSONEncoder()
    private lazy var jsonDecoder = JSONDecoder()

    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        try! self.init(context: context)
    }
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCD> = {
        let fetchRequest = NSFetchRequest<TrackerCD>(entityName: "TrackerCD")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()


    init(context: NSManagedObjectContext? = nil) throws {
        if let context {
            self.context = context
        } else {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                preconditionFailure("Something went terribly wrong")
            }

            self.context = appDelegate.persistentContainer.viewContext
        }
        super.init()

        let fetchRequest = TrackerCD.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        self.fetchedResultsController = controller
        try controller.performFetch()
    }

    var categories: [TrackerCategory] {

        do {
            try fetchedResultsController.performFetch()
        } catch let error {
            print(error.localizedDescription)
        }
        let doneRequest = NSFetchRequest<TrackerCD>(entityName: "TrackerCD")
        let startOfDay = calendar.startOfDay(for: currentDate)
        do {
            _ = try context.fetch(doneRequest)
            guard let trackersCD = fetchedResultsController.fetchedObjects
            else { return [] }
            var categoriesCD: [TrackerCategoryCD] = []
            var result: [TrackerCategory] = []
            trackersCD.forEach {
                let category = $0.category
                let containsCategory = categoriesCD.contains { $0.id == category?.id }
                if !containsCategory {
                    guard let category = category else {return}
                    categoriesCD.append(category)
                }
            }
            categoriesCD.forEach {
                guard let currentCategory = TrackerCategory.fromCoreData($0, decoder: jsonDecoder) else {return}
                let trackers = trackersCD.filter { $0.category?.id == currentCategory.id }
                result.append(TrackerCategory(id: currentCategory.id, label: currentCategory.label, trackers: trackers.compactMap{ Tracker.fromCoreData($0, decoder: jsonDecoder, isCompleted:  $0.records?.contains(where: {($0 as! TrackerRecordCD).date == startOfDay}) ?? false, recordsCount: $0.records?.count) }))
            }

            return filteredData(categories: result)
        } catch let error {
            print(error.localizedDescription)
        }
        return []
    }

    func filteredData(categories: [TrackerCategory]) -> [TrackerCategory] {
        guard let selectedWeekday = WeekDay(
            rawValue: Calendar.current.component(.weekday, from: currentDate)
        ) else { preconditionFailure("Weekday must be in range of 1...7") }
        let emptySearch = searchText.isEmpty
        var result = [] as [TrackerCategory]
        categories.forEach { category in
            let categoryIsInSearch = emptySearch || category.label.lowercased().contains(searchText)

            let filteredTrackers = category.trackers.filter { tracker in
                let trackerIsInSearch = emptySearch || tracker.label.lowercased().contains(searchText)
                let isForDate = tracker.schedule?.contains(selectedWeekday) ?? true
                return (categoryIsInSearch || trackerIsInSearch) && isForDate
            }
            if !filteredTrackers.isEmpty {
                let newFilteredCategory = TrackerCategory(
                    label: category.label,
                    trackers: filteredTrackers
                )
                result.append(newFilteredCategory)
            }
        }
        return result
    }
    
    func addNewCategory(_ newCategory: TrackerCategory) throws {
        let TrackerCategoryCoreData = TrackerCategoryCD(context: context)
        updateExistingCategory(TrackerCategoryCoreData, with: newCategory)
        try context.save()
    }

    func updateExistingCategory(_ trackerCategoryCoreData: TrackerCategoryCD, with category: TrackerCategory) {
        trackerCategoryCoreData.label = category.label
        trackerCategoryCoreData.id = category.id
        trackerCategoryCoreData.createdAt = Date()
        trackerCategoryCoreData.trackers = []
    }

    func extractAllCategoriesAsArray() -> [TrackerCategory] {
        let request = NSFetchRequest<TrackerCategoryCD>(entityName: "TrackerCategoryCD")
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        var categoriesCD: [TrackerCategoryCD] = []
        do {
            categoriesCD = try context.fetch(request)
        } catch {
            print("Error fetching categoriesCD: \(error)")
        }
        let categories = categoriesCD.compactMap { TrackerCategory.fromCoreData($0, decoder: jsonDecoder) }
        return categories
    }

    func extractCategoryById(id: UUID) -> TrackerCategoryCD? {
        let request = NSFetchRequest<TrackerCategoryCD>(entityName: "TrackerCategoryCD")
        request.predicate = NSPredicate(format: "%K == %@", "id", id as CVarArg)
        request.fetchLimit = 1

        return try? context.fetch(request).first
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
        let trackers = trackersCD.compactMap { Tracker.fromCoreData($0, decoder: jsonDecoder, isCompleted: nil, recordsCount: nil) }
        return trackers
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

    func deleteRecord(tracker: TrackerCD, date: Date) throws {
        guard let id = tracker.id else { return }
        guard let recordCD = extractRecordByTrackerIdAndDate(id: id, date: date) else { return }
        context.delete(recordCD)
        try context.save()
    }

    func extractAllRecordsAsArray() -> [TrackerRecord] {
        let request = NSFetchRequest<TrackerRecordCD>(entityName: "TrackerRecordCD")
        let recordsCD = try! context.fetch(request)
        let records = recordsCD.compactMap { TrackerRecord.fromCoreData($0) }
        return records
    }

    func extractRecordByTrackerIdAndDate(id: UUID, date: Date) -> TrackerRecordCD? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let request = NSFetchRequest<TrackerRecordCD>(entityName: "TrackerRecordCD")
        request.predicate = NSPredicate(format: "%K == %@", "id", id as CVarArg)
        request.predicate = NSPredicate(format: "tracker.id == %@ AND date == %@", id as CVarArg, startOfDay as NSDate)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension Store: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {}

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate()
    }
}

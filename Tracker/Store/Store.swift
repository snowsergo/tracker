import UIKit
import CoreData

protocol StoreDelegate: AnyObject {
    func didUpdate()
}

final class Store: NSObject {
    private let context: NSManagedObjectContext
    weak var delegate: StoreDelegate?
    let calendar = Calendar.current
    var trackerStore = TrackerStore()
    var trackerCategoryStore = TrackerCategoryStore()
    var trackerRecordStore = TrackerRecordStore()

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


    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()

        let fetchRequest = TrackerCD.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        self.fetchedResultsController = controller
        try controller.performFetch()
    }

    var categories: [TrackerCategory] {

        do {
            let startOfDay = calendar.startOfDay(for: currentDate)
            fetchedResultsController.fetchRequest.predicate =  NSPredicate(format: "SUBQUERY(records, $r, $r.date == %@).@count == 0 AND category != nil", startOfDay as CVarArg)
            try fetchedResultsController.performFetch()
        } catch let error {
            print(error.localizedDescription)
        }
        let doneRequest = NSFetchRequest<TrackerCD>(entityName: "TrackerCD")

        do {
            let fetchedDoneData = try context.fetch(doneRequest)
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
                result.append(TrackerCategory(id: currentCategory.id, label: currentCategory.label, trackers: trackersCD.filter { $0.category!.id == currentCategory.id }.compactMap{ Tracker.fromCoreData($0, decoder: jsonDecoder) }))
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
}

// MARK: - NSFetchedResultsControllerDelegate
extension Store: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {}

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate()
    }
}

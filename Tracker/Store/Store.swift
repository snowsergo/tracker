import UIKit
import CoreData

protocol StoreDelegate: AnyObject {
    func didUpdate()
}

final class Store: NSObject {
    private let context: NSManagedObjectContext
//    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCD>!
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

//    func filteredData() -> [TrackerCategory] {
//        guard let selectedWeekday = WeekDay(
//            rawValue: Calendar.current.component(.weekday, from: currentDate)
//        ) else { preconditionFailure("Weekday must be in range of 1...7") }
//        let emptySearch = searchText.isEmpty
//        var result = [] as [TrackerCategory]
//        store.categories.forEach { category in
//            let categoryIsInSearch = emptySearch || category.label.lowercased().contains(searchText)
//
//            let filteredTrackers = category.trackers.filter { tracker in
//                let trackerIsInSearch = emptySearch || tracker.label.lowercased().contains(searchText)
//                let isForDate = tracker.schedule?.contains(selectedWeekday) ?? true
//                let isCompletedForDate = completedTrackers[currentDate]?.contains(
//                    .init(trackerId: tracker.id, date: currentDate)
//                ) ?? false
//
//                return (categoryIsInSearch || trackerIsInSearch) && isForDate
//                && !isCompletedForDate
//            }
//            if !filteredTrackers.isEmpty {
//                let newFilteredCategory = TrackerCategory(
//                    label: category.label,
//                    trackers: filteredTrackers
//                )
//                result.append(newFilteredCategory)
//            }
//        }
//        return result
//    }

//    request.predicate = NSPredicate(format: "%K.%K == %@ AND %K < %ld",
//                  // Книга с автором из США: author.country == USA
//                  #keyPath(Book.author), #keyPath(Author.country), "USA",
//                  // Книга выпущена до 1990: year < 1990
//                  #keyPath(Book.year), 1990)

//    request.predicate = NSPredicate(format: "%K CONTAINS[n] %@", #keyPath(Book.title), "Harry")
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCD> = {
//        let calendar = Calendar.current
//        let today = Date()
//        let startOfDay = calendar.startOfDay(for: today)
//        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)

        let fetchRequest = NSFetchRequest<TrackerCategoryCD>(entityName: "TrackerCategoryCD")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
//        fetchRequest.predicate = NSPredicate(format: "SUBQUERY(trackers, $tracker, NOT (ANY $tracker.records.date >= %@ AND $tracker.records.date < %@)).@count > 0", startOfDay as NSDate, endOfDay! as NSDate)
        fetchRequest.predicate = NSPredicate(format: "trackers.@count == 100")

//                fetchRequest.predicate = NSPredicate(format: "records.@count == 0")
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        print("_______________обновляем запрос_________")
        return fetchedResultsController
    }()


    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()

        let fetchRequest = TrackerCategoryCD.fetchRequest()
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
        guard
        let categoriesCD = fetchedResultsController.fetchedObjects

        else { return [] }
        print("categoriesCD = = = = ",categoriesCD)
        let result = categoriesCD.compactMap{ TrackerCategory.fromCoreData($0, decoder: jsonDecoder) }
//        print("___cat = ",result)
        return filteredData(categories: result)
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

//                    let isCompletedForDate = completedTrackers[currentDate]?.contains(
//                        .init(trackerId: tracker.id, date: currentDate)
//                    ) ?? false

                    return (categoryIsInSearch || trackerIsInSearch) && isForDate
//                    && !isCompletedForDate
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

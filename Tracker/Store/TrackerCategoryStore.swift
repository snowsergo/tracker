import UIKit
import CoreData

final class TrackerCategoryStore {
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
        let categoriesCD = try! context.fetch(request)
        let categories = categoriesCD.compactMap { TrackerCategory.fromCoreData($0, decoder: jsonDecoder) }
        return categories
    }

    func extractCategoryById(id: UUID) -> TrackerCategoryCD? {
        let request = NSFetchRequest<TrackerCategoryCD>(entityName: "TrackerCategoryCD")
        request.predicate = NSPredicate(format: "%K == %@", "id", id as CVarArg)
        request.fetchLimit = 1
        
        return try? context.fetch(request).first
    }
}


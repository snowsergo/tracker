import UIKit
import CoreData

final class TrackerCategoryStore {
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

    func addNewCategory(_ newCategory: TrackerCategory) throws {
        let TrackerCategoryCoreData = TrackerCategoryCD(context: context)
        updateExistingCategory(TrackerCategoryCoreData, with: newCategory)
        try context.save()
        print("____CD____addCATEGORY___2")

    }

    func updateExistingCategory(_ trackerCategoryCoreData: TrackerCategoryCD, with category: TrackerCategory) {
        trackerCategoryCoreData.label = category.label
        trackerCategoryCoreData.id = UUID()
        trackerCategoryCoreData.createdAt = Date()
//        trackerCategoryCoreData.trackers = []
        print("____CD____addCATEGORY___1")
    }

    func getAllCategories() -> [TrackerCategory] {
            // Создаём запрос.
            // Укажем, что хотим получить записи Author и ответ привести к типу Author.
            let request = NSFetchRequest<TrackerCategoryCD>(entityName: "TrackerCategoryCD")
            // Выполняем запрос, используя контекст.
            // В результате получаем массив объектов Author.
            let categoriesCD = try! context.fetch(request)
            // Распечатаем в консоль имена и год автора.
        let categories = categoriesCD.compactMap { TrackerCategory.fromCoreData($0, decoder: jsonDecoder) }
        categories.forEach { print("категория из бд \($0.label ?? "пустое слово")") }
        return categories
    }
}


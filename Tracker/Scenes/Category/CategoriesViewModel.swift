import UIKit

final class CategoriesViewModel {
    var onChange: (() -> Void)?

    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            onChange?()
        }
    }
    var selectedCategory: TrackerCategory? {
        didSet {
            onChange?()
        }
    }
    private let store: Store


    convenience init() {
        let store = try! Store(
            context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        )
        self.init(store: store)
    }
    init(store: Store) {
        self.store = store
        store.delegate = self
        categories = getCategoriesFromStore()
    }

    func addCategory(newCategory: TrackerCategory) {
        try? store.addNewCategory(newCategory)
        didUpdate()
    }

    private func getCategoriesFromStore() -> [TrackerCategory] {
        return store.extractAllCategoriesAsArray()
    }
}

extension CategoriesViewModel: StoreDelegate {
    func didUpdate() {
        categories = getCategoriesFromStore()
    }
}

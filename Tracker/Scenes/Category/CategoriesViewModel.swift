import UIKit

final class CategoriesViewModel {
    var onChange: (() -> Void)?

    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            print("---did Set")
            onChange?() // сообщаем через замыкание, что ViewModel изменилась
        }
    }
    var selectedCategory: TrackerCategory? {
        didSet {
//            onChange?() // сообщаем через замыкание, что ViewModel изменилась
        }
    }
    private let store: Store

    convenience init() {
        let store = Store()
        self.init(store: store)
    }

    init(store: Store) {
        self.store = store
        store.delegate = self
        categories = getCategoriesFromStore()
    }

    func addCategory(newCategory: TrackerCategory) {
        print(" /___ addCategory")
       try? store.addNewCategory(newCategory)
    }

    private func getCategoriesFromStore() -> [TrackerCategory] {
        print(" / _____getCategoriesFromStore")
        return store.categories
    }
}

extension CategoriesViewModel: StoreDelegate {
    func didUpdate() {
        print(" / 1___didUpdate____")
        categories = getCategoriesFromStore()
    }
}

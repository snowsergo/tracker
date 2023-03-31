import UIKit
import CoreData

final class TrackerCategoryStore {
    var store: Store
    
    init(store: Store) {
        self.store = store
    }
    
    func addNewCategory(_ newCategory: TrackerCategory)  {
        try? store.addNewCategory(newCategory)
    }
    
    func extractAllCategoriesAsArray() -> [TrackerCategory] {
        return  store.extractAllCategoriesAsArray()
    }
    
    func extractCategoryById(id: UUID) -> TrackerCategoryCD? {
        return store.extractCategoryById(id: id)
        
    }
}


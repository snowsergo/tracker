import Foundation

final class StatisticsService {
    private let store: Store

    var completedRecordsCount = 0
    
    init(store: Store) {
        self.store = store
    }
    
    func trackersCompleted() -> Int {
        completedRecordsCount = store.getCompletedTrackerRecordsCount()
        return completedRecordsCount
    }
}

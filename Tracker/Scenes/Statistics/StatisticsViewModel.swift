import Foundation

final class StatisticsViewModel {
    private var model: StatisticsService
    var trackersCompleted = 00
    var onStatisticsRefreshed: (() -> Void)?
    
    init(model: StatisticsService) {
        self.model = model
    }
    
    func getStatistic() {
        trackersCompleted = model.trackersCompleted()
        onStatisticsRefreshed?()
    }
}

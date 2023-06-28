import Foundation

final class FiltersViewModel {
    var selectedFilter: TrackersFilter
    let filters: [TrackersFilterDescription] = [
        TrackersFilterDescription(value: .today, description: NSLocalizedString("trackersFilterToday", comment: "")),
        TrackersFilterDescription(value: .todayCompleted, description: NSLocalizedString("trackersFilterTodayCompleted", comment: "")),
        TrackersFilterDescription(value: .todayUncompleted, description: NSLocalizedString("trackersFilterTodayUncompleted",comment: ""))
    ]
    var onFilterSelect: ((TrackersFilter) -> Void)?
    
    init(selectedFilter: TrackersFilter) {
        self.selectedFilter = selectedFilter
    }
    
    func filterTap(_ indexPath: IndexPath) {
        onFilterSelect?(filters[indexPath.row].value)
    }

    func filtersCount() -> Int {
        filters.count
    }

}

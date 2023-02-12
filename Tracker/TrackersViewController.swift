import UIKit

final class TrackersViewController: UIViewController {

    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate: Date = Date()
    private let datePicker: UIDatePicker = UIDatePicker()
    private var searchText: String = ""
    private var isFiltered: Bool = false

    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupTabBar()
        visibleCategories = filteredData()
        print("visibleCategories", visibleCategories)
        setupCollectionView()
        view.backgroundColor = .white
    }

    private func setupNavBar() {
        if let navBar = navigationController?.navigationBar {
            navBar.prefersLargeTitles = true
            //            navBar.backgroundColor = .white
            navigationItem.title = "Трекеры";
            navigationItem.leftBarButtonItem = addButton
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
            datePicker.translatesAutoresizingMaskIntoConstraints = false
            datePicker.preferredDatePickerStyle = .compact
            datePicker.datePickerMode = .date
            datePicker.layer.cornerRadius = 8
            datePicker.layer.masksToBounds = true
            datePicker.addTarget(self, action: #selector(dateHandler(_:)), for: .valueChanged)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
            NSLayoutConstraint.activate([
                datePicker.widthAnchor.constraint(lessThanOrEqualToConstant: 100)
            ])
        }

        let search = UISearchController(searchResultsController: nil)
        search.delegate = self
        search.searchBar.delegate = self
        self.navigationItem.searchController = search

    }

    private func setupTabBar(){
        if let tabBar = tabBarController?.tabBar {
            let lineView = UIView(frame: CGRect(x: 0, y: 0, width: tabBar.frame.size.width, height: 1))
            lineView.backgroundColor = .asset(.grey)
            tabBar.addSubview(lineView)
        }
    }

    private lazy var addButton: UIBarButtonItem = {
        let addIcon = UIImage(
            systemName: "plus",
            withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)
        )
        let addButton = UIBarButtonItem(
            image: addIcon,
            style: .plain,
            target: self,
            action: #selector(addTracker)
        )
        addButton.tintColor = .asset(.black)
        return addButton
    }()

    @objc private func dateHandler(_ sender: UIDatePicker) {
        currentDate = sender.date
        print("currentDate = ", currentDate)
    }

    @objc
    private func addTracker() {
        let trackerSelect = TrackerSelectViewController(){ [weak self] newTracker in
            guard let self else { return }
            //            print("!!! new tracker = ", newTracker);
            if self.categories.isEmpty {
                let newCategory = TrackerCategory(
                    label: "Тестовая категория",
                    trackers: [newTracker]
                )
                self.categories = [newCategory]

            }
            else {
                let newCategories = self.categories
                var trackers = newCategories[0].trackers
                trackers.append(newTracker)
                self.categories = newCategories
            }
            self.visibleCategories = self.filteredData()
            print("visibleCategories = ", self.visibleCategories)
//            self.collectionView.reloadData()
        }
        present(trackerSelect, animated: true)
    }


    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(collectionView)
        //        view.backgroundColor = .white

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}


// collection view
extension TrackersViewController: UICollectionViewDataSource {


    func numberOfSections(in collectionView: UICollectionView) -> Int { visibleCategories.count}

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return visibleCategories[section].trackers.count }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! TrackerCollectionViewCell

        cell.configure(with: visibleCategories[indexPath.section].trackers[indexPath.item])
        return cell
    }
}

extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}


extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 2, height: 50)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }
}

//search
extension TrackersViewController: UISearchControllerDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchText = ""
        isFiltered = false
        //        self.tableView.reloadData()
    }
}

extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            self.searchText = ""
            isFiltered = false
            //            self.tableView.reloadData()
            return
        }
        self.searchText = searchText
        isFiltered = true
        //        self.tableView.reloadData()
    }
}


// filters date and text
private extension TrackersViewController {
    //    var filteredCategories: [TrackerCategory]
    //    type FilteredData = [TrackerCategory]

    //    func applySnapshot(animatingDifferences: Bool = true) {
    //        var snapshot = Snapshot()
    //
    //        filteredData.forEach {
    //            snapshot.appendSections([$0.category])
    //            snapshot.appendItems($0.trackers, toSection: $0.category)
    //        }
    //
    //        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    //
    //        updatePlaceholderVisibility()
    //    }

    func filteredData() -> [TrackerCategory] {
        print(" - - - - вызов filteredData - - - - ")
        guard let selectedWeekday = WeekDay(
            rawValue: Calendar.current.component(.weekday, from: currentDate)
        ) else { preconditionFailure("Weekday must be in range of 1...7") }
        print("selectedWeekday = ", selectedWeekday)
        let emptySearch = searchText.isEmpty
        var result = [] as [TrackerCategory]
        print("emptySearch = ", emptySearch)
        categories.forEach { category in
            let categoryIsInSearch = emptySearch || category.label.lowercased().contains(searchText)

            let filteredTrackers = category.trackers.filter { tracker in
                let trackerIsInSearch = emptySearch || tracker.label.lowercased().contains(searchText)
                let isForDate = tracker.schedule?.contains(selectedWeekday) ?? true
                //                let isCompletedForDate = completedTrackers[currentDate].contains(
                //                    .init(trackerId: tracker.id, date: currentDate)
                //                ) ?? false

                return (categoryIsInSearch || trackerIsInSearch) && isForDate
                //                && !isCompletedForDate
            }
            print("filteredTrackers = ", filteredTrackers);
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

//// MARK: - Configuration
//
//extension TrackerCollectionViewCell {
//    func configure(with model: Tracker?) {
//        trackerLabel.text = model?.label
//        dayLabel.text = model != nil ? "?? день" : nil
//        emojiLabel.text = model?.emoji
//
//        colorBackground.backgroundColor = model?.color.uiColor
//        addButton.backgroundColor = model?.color.uiColor
//    }
//}
//

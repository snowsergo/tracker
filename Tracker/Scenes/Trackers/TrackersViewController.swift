import UIKit

final class TrackersViewController: UIViewController {
    
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [Date: Set<TrackerRecord>] = [:]
    private var currentDate: Date = Date()
    private let datePicker: UIDatePicker = UIDatePicker()
    private var searchText: String = ""
    private var isFiltered: Bool = false

    private var trackerStore = TrackerStore()
    private var trackerCategoryStore = TrackerCategoryStore()
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.keyboardDismissMode = .onDrag
        collectionView.contentInset = .init(top: 10, left: 0, bottom: 0, right: 0)
        
        collectionView.register(
            TrackerCategoryHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "Header"
        )
        
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupTabBar()
        categories = trackerCategoryStore.getAllCategories()
        visibleCategories = filteredData()
        setupCollectionView()
        setupPlaceHolders()
        updatePlaceholderVisibility()
        view.backgroundColor = .white
    }

  

    //настройка навбара сверху
    private func setupNavBar() {
        if let navBar = navigationController?.navigationBar {
            navBar.prefersLargeTitles = true
            navBar.standardAppearance.largeTitleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.asset(.black),
                NSAttributedString.Key.font: UIFont.asset(.ysDisplayBold, size: 34)
            ]
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

    func updatePlaceholderVisibility() {
        let viewIsEmpty = visibleCategories.count == 0
        let haveNoTrackers = categories.filter({ $0.trackers.count > 0 }).count == 0

        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self else { return }

            self.startPlaceholderView.alpha = viewIsEmpty && haveNoTrackers ? 1 : 0
            self.emptyPlaceholderView.alpha = viewIsEmpty && !haveNoTrackers ? 1 : 0
        }
    }

    //настройка таббара снзу
    private func setupTabBar(){
        if let tabBar = tabBarController?.tabBar {
            let lineView = UIView(frame: CGRect(x: 0, y: 0, width: tabBar.frame.size.width, height: 1))
            lineView.backgroundColor = .asset(.lightGrey)
            tabBar.addSubview(lineView)
            let tabItemsAppearance = UITabBarItemAppearance()
            tabItemsAppearance.normal.titleTextAttributes = [
                NSAttributedString.Key.font: UIFont.asset(.ysDisplayMedium, size: 10)
            ]
        }
    }


    private func setupPlaceHolders(){
        view.addSubview(startPlaceholderView)
        view.addSubview(emptyPlaceholderView)

        NSLayoutConstraint.activate([
            startPlaceholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            startPlaceholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyPlaceholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyPlaceholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    private lazy var startPlaceholderView: UIView = {
        let view = UIView.placeholderView(
            message: "Что будем отслеживать?",
            icon: .trackerStartPlaceholder
        )

        view.alpha = 0

        return view
    }()

    private lazy var emptyPlaceholderView: UIView = {
        let view = UIView.placeholderView(
            message: "Ничего не найдено",
            icon: .trackerEmptyPlaceholder
        )

        view.alpha = 0

        return view
    }()

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
    
    func setTrackerCompleted(_ cell: TrackerCollectionViewCell) {
        print("setTrackerCompleted")
        guard
            let indexPath = collectionView.indexPath(for: cell)
        else {
            assertionFailure("Can't find cell")
            return
        }
        print("categories = ", categories)
        print("indexPath = ", indexPath)
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        var completedTrackersForDay = completedTrackers[currentDate, default: []]
        completedTrackersForDay.insert(.init(trackerId: tracker.id, date: currentDate))
        completedTrackers[currentDate] = completedTrackersForDay
        self.visibleCategories = self.filteredData()
        self.collectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    @objc private func dateHandler(_ sender: UIDatePicker) {
        currentDate = sender.date
        visibleCategories = filteredData()
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }


    func addNewTracker(newTracker: Tracker, categoryId: UUID) {
        //        if self.categories.isEmpty {
        //            let newCategory = TrackerCategory(
        //                label: "Тестовая категория",
        //                trackers: [newTracker]
        //            )
        //            self.categories = [newCategory]
        //
        //        }
        //        else {

        if let i = categories.firstIndex(where: { $0.id == categoryId }) {
            // do something with foo
            var trackers = categories[i].trackers
            trackers.append(newTracker)
            let newCategory = TrackerCategory(label: categories[i].label, trackers: trackers)
            self.categories[i] = newCategory
        } else {
            // item could not be found
            let newCategory = TrackerCategory(
                label: "Тестовая категория",
                trackers: [newTracker]
            )
            self.categories.append(newCategory)
        }

        //            var trackers = self.categories[0].trackers
        //            trackers.append(newTracker)
        //            let newCategory = TrackerCategory(label: self.categories[0].label, trackers: trackers)
        //            self.categories[0] = newCategory
        //        }
        self.visibleCategories = self.filteredData()
        self.collectionView.reloadData()
        self.updatePlaceholderVisibility()
    }

    //добавление трекера
    @objc
    private func addTracker() {
        let trackerSelect = TrackerSelectViewController(categories: categories, addingTrackerCompletion: addNewTracker, addingCategoryCompletion: addNewCategory)
        //        { [weak self] newTracker in
        //            guard let self else { return }
        //            if self.categories.isEmpty {
        //                let newCategory = TrackerCategory(
        //                    label: "Тестовая категория",
        //                    trackers: [newTracker]
        //                )
        //                self.categories = [newCategory]
        //
        //            }
        //            else {
        //                var trackers = self.categories[0].trackers
        //                trackers.append(newTracker)
        //                let newCategory = TrackerCategory(label: self.categories[0].label, trackers: trackers)
        //                self.categories[0] = newCategory
        //            }
        //            self.visibleCategories = self.filteredData()
        //            self.collectionView.reloadData()
        //            self.updatePlaceholderVisibility()
        //        }
        present(trackerSelect, animated: true)
    }
    //добавление категории
    //    @objc
    //    private
    func addNewCategory(newCategory: TrackerCategory) {
        print("добавляем категорию в главный список")
        //        let categoryCreationViewController = CategoryCreationViewController(){ [weak self] newCategory in
        //            guard let self else { return }
        var categories = self.categories
        categories.append(newCategory)
        do {
            try trackerCategoryStore.addNewCategory(newCategory)

        }
        catch {
            print(error)
        }

        self.categories = categories
        self.visibleCategories = self.filteredData()
        self.collectionView.reloadData()
        self.updatePlaceholderVisibility()
        print("main-categories = ", categories);
        //        }
        //        present(categoryCreationViewController, animated: true)
    }
    
    // настройка коллекции
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionView)
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}


// collection view
extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { visibleCategories.count}
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return visibleCategories[section].trackers.count }
    
    //ячейка трекера
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! TrackerCollectionViewCell
        
        cell.configure(with: visibleCategories[indexPath.section].trackers[indexPath.item])
        cell.delegate = self
        return cell
    }
    
    //хедер с названием категории
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! TrackerCategoryHeaderView
        header.configure(label: visibleCategories[indexPath.section].label)
        return header
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
        return CGSize(width: (collectionView.bounds.width - 9 - 32) / 2, height: 148)
        //        return CGSize(width: (collectionView.bounds.width - 9) / 2, height: 148)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 30)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 10, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        0
    }
}

//search
extension TrackersViewController: UISearchControllerDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchText = ""
        isFiltered = false
        self.visibleCategories = filteredData()
        self.collectionView.reloadData()
        updatePlaceholderVisibility()
    }
}

extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            self.searchText = ""
            isFiltered = false
            self.visibleCategories = filteredData()
            self.collectionView.reloadData()
            return
        }
        self.searchText = searchText
        isFiltered = true
        self.visibleCategories = filteredData()
        self.collectionView.reloadData()
        updatePlaceholderVisibility()
    }
}

// filters date and text
private extension TrackersViewController {
    func filteredData() -> [TrackerCategory] {
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
                let isCompletedForDate = completedTrackers[currentDate]?.contains(
                    .init(trackerId: tracker.id, date: currentDate)
                ) ?? false
                
                return (categoryIsInSearch || trackerIsInSearch) && isForDate
                && !isCompletedForDate
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

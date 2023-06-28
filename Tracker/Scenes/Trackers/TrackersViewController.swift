import UIKit

final class TrackersViewController: UIViewController {
    private var categories: [TrackerCategory] = []
    private var allCategories: [TrackerCategory]=[]
    private var currentDate: Date = Date()
    private let datePicker: UIDatePicker = UIDatePicker()
    private var searchText: String = ""
    private var isFiltered: Bool = false
    
    private let screenName = "Main"
    private let analyticsServices: AnalyticsServicesProtocol?
    
    private var store: Store
    private var trackersStore: TrackerStore
    private var categoriesStore: TrackerCategoryStore
    private var trackerRecordsStore: TrackerRecordStore
    
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
    
    private let filtersButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.asset(.blue)
        button.setTitle(NSLocalizedString("filters",comment: ""), for: .normal)
        button.setTitleColor(UIColor.asset(.white), for: .normal)
        button.layer.cornerRadius = 16
        button.contentEdgeInsets = UIEdgeInsets(top: 14, left: 20, bottom: 14, right: 20)
        button.sizeToFit()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(store: Store ,analyticsServices: AnalyticsServicesProtocol? = nil) {
        self.store = store
        categoriesStore = TrackerCategoryStore(store: store)
        trackersStore = TrackerStore(store: store)
        trackerRecordsStore = TrackerRecordStore(store: store)
        self.analyticsServices = analyticsServices
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupTabBar()
        store.delegate = self
        categories = prepareCategories(categories: store.categories, filter: store.trackersFilter)
        allCategories = categoriesStore.extractAllCategoriesAsArray()
        setupCollectionView()
        setupPlaceHolders()
        updatePlaceholderVisibility()
        view.backgroundColor = UIColor.asset(.white)
        
        view.addSubview(filtersButton)
        
        NSLayoutConstraint.activate([
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
        
        filtersButton.addTarget(self, action: #selector(showFilteringMenu), for: .touchUpInside)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        analyticsServices?.openScreen(screen: screenName)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        analyticsServices?.closeScreen(screen: screenName)
    }
    
    private func prepareCategories(categories: [TrackerCategory], filter: TrackersFilter) -> [TrackerCategory] {
        var updatedCategories: [TrackerCategory] = []
        var pinnedTrackers: [Tracker] = []
        
        for category in categories {
            var updatedTrackers: [Tracker]
            
            switch filter {
            case .today:
                updatedTrackers = category.trackers
            case .todayCompleted:
                updatedTrackers = category.trackers.filter { $0.isCompleted ?? false }
            case .todayUncompleted:
                updatedTrackers = category.trackers.filter { !($0.isCompleted ?? false) }
            }
            
            let nonPinnedTrackers = updatedTrackers.filter { !$0.pinned }
            let pinnedTrackersInCategory = updatedTrackers.filter { $0.pinned }
            
            if !nonPinnedTrackers.isEmpty {
                let updatedCategory = TrackerCategory(id: category.id, label: category.label, trackers: nonPinnedTrackers)
                updatedCategories.append(updatedCategory)
            }
            
            pinnedTrackers.append(contentsOf: pinnedTrackersInCategory)
        }
        
        if !pinnedTrackers.isEmpty {
            let pinnedCategory = TrackerCategory(id: UUID(), label: "Закрепленные", trackers: pinnedTrackers)
            updatedCategories.insert(pinnedCategory, at: 0)
        }
        
        return updatedCategories
    }
    
    
    //настройка навбара сверху
    private func setupNavBar() {
        if let navBar = navigationController?.navigationBar {
            navBar.prefersLargeTitles = true
            navBar.standardAppearance.largeTitleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.asset(.black),
                NSAttributedString.Key.font: UIFont.asset(.ysDisplayBold, size: 34)
            ]
            navBar.backgroundColor = UIColor.asset(.white)
            navBar.standardAppearance.backgroundColor = UIColor.asset(.white)
            navigationItem.title = NSLocalizedString("trackers", comment: "");
            
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
        let viewIsEmpty = categories.count == 0
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
        analyticsServices?.tapOn(screen: screenName, item: Const.analyticsIdentifierForTracker)
        guard
            let indexPath = collectionView.indexPath(for: cell)
        else {
            assertionFailure("Can't find cell")
            return
        }
        let tracker = categories[indexPath.section].trackers[indexPath.row]
        let isCompleted = tracker.isCompleted
        guard let trackerCD = trackersStore.extractTrackerById(id: tracker.id) else {
            return
        }
        if isCompleted == true {
            try? trackerRecordsStore.deleteRecord(tracker: trackerCD, date: store.currentDate)
        } else {
            try? trackerRecordsStore.addNewRecord(tracker: trackerCD, date: store.currentDate)
        }
        
        didUpdate()
        updatePlaceholderVisibility()
    }
    
    @objc private func showFilteringMenu() {
        analyticsServices?.tapOn(screen:screenName, item: Const.analyticsIdentifierForFilterButton)
        
        let filtersViewModel = FiltersViewModel(selectedFilter: store.trackersFilter)
        filtersViewModel.onFilterSelect = { [weak self] selectedFilter in
            self?.store.trackersFilter = selectedFilter
            self?.dismiss(animated: true)
            self?.didUpdate()
        }
        
        let filtersVC = FiltersViewController(viewModel: filtersViewModel)
        present(filtersVC, animated: true)
    }
    @objc private func dateHandler(_ sender: UIDatePicker) {
        store.currentDate = sender.date
        didUpdate()
        updatePlaceholderVisibility()
    }
    
    
    func addNewTracker(newTracker: Tracker, categoryId: UUID) {
        guard let categoryCD = categoriesStore.extractCategoryById(id: categoryId) else {
            return
        }
        trackersStore.addNewTracker(newTracker, category: categoryCD)
        self.didUpdate()
        self.updatePlaceholderVisibility()
    }
    
    func editTracker(trackerCD: TrackerCD, newTracker: Tracker, categoryId: UUID) {
        guard let categoryCD = categoriesStore.extractCategoryById(id: categoryId) else {
            return
        }
        trackersStore.updateTracker(trackerCD: trackerCD, newTracker: newTracker, category: categoryCD)
        self.didUpdate()
        self.updatePlaceholderVisibility()
    }
    
    
    //добавление трекера
    @objc
    private func addTracker() {
        analyticsServices?.tapOn(screen: screenName, item: Const.analyticsIdentifierForAddButton)
        
        let trackerSelect = TrackerSelectViewController(categories: allCategories, addingTrackerCompletion: addNewTracker, addingCategoryCompletion: addNewCategory)
        present(trackerSelect, animated: true)
    }
    
    @objc private func deleteConfirmationDialog(tracker: TrackerCD) {
        let deleteDialog = UIAlertController(title: "Удалить?",
                                             message: nil, preferredStyle: .actionSheet)
        
        deleteDialog.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            try? self?.trackersStore.deleteTracker(tracker: tracker)
        })
        deleteDialog.addAction(UIAlertAction(title: "Отменить", style: .cancel))
        
        present(deleteDialog, animated: true)
    }
    
    
    func addNewCategory(newCategory: TrackerCategory) {
        categoriesStore.addNewCategory(newCategory)
        self.didUpdate()
        self.updatePlaceholderVisibility()
    }
    
    // настройка коллекции
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.asset(.white)
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { categories.count}
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return categories[section].trackers.count }
    
    //ячейка трекера
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! TrackerCollectionViewCell
        
        cell.configure(with: categories[indexPath.section].trackers[indexPath.item])
        cell.delegate = self
        return cell
    }
    
    //хедер с названием категории
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! TrackerCategoryHeaderView
        header.configure(label: categories[indexPath.section].label)
        return header
    }
}


extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    
    // вызов контекстного меню
    internal func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let tracker = categories[indexPath.section].trackers[indexPath.row]
        let isPinned = tracker.pinned
        let pinUnpinTitle = isPinned ? "Открепить" : "Закрепить"
        
        let action1 = UIAction(title: pinUnpinTitle) { [weak self] _ in
            self?.handlePined(tracker: tracker)
            
        }
        let action2 = UIAction(title: "Редактировать") { [weak self] _ in
            self?.analyticsServices?.tapOn(screen: self?.screenName ?? "Main", item: Const.analyticsIdentifierForTrackerContextMenuEdit)
            self?.makeEdit(tracker: tracker)
        }

        let deleteActionTitle = NSAttributedString(string: "Удалить", attributes: [.foregroundColor: UIColor.asset(.red)])
          let action3 = UIAction(title: "", image: nil, identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off) { [weak self] _ in
              self?.analyticsServices?.tapOn(screen: self?.screenName ?? "Main", item: Const.analyticsIdentifierForTrackerContextMenuDelete)
              self?.makeDelete(tracker: tracker)
          }
          action3.setValue(deleteActionTitle, forKey: "attributedTitle")

        let menu = UIMenu(title: "", children: [action1, action2, action3])
        let menuConfiguration = UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: {
            let customView = self.makePreview(tracker: tracker)
            return customView
        }) { _ in
            return UIMenu(title: "", children: [action1, action2, action3])
        }
        return menuConfiguration
    }
    private func makePreview(tracker: Tracker) -> UIViewController {
        let viewController = UIViewController()
        let preview = TrackersSubviewCell(frame: CGRect(x: 0, y: 0, width: 167, height: 90))
        viewController.view = preview
        preview.setupView(tracker: tracker)
        viewController.view.backgroundColor = UIColor(hex: tracker.color + "ff")
        
        viewController.preferredContentSize = preview.frame.size
        
        return viewController
    }
    
    func makeEdit(tracker: Tracker) {
        guard let trackerCD = trackersStore.extractTrackerById(id: tracker.id) else {
            return
        }
        
        let viewController = TrackerCreationViewController(categories: categories, isRegular: tracker.schedule != nil ? true : false, editingCompletion: editTracker, completion: nil, addingCategoryCompletion: addNewCategory, editableTracker: trackerCD)
        
        self.present(viewController, animated: true)
    }
    
    func handlePined(tracker: Tracker) {
        guard let trackerCD = trackersStore.extractTrackerById(id: tracker.id) else {
            return
        }
        try? self.trackersStore.togglePinned(tracker: trackerCD)
    }
    
    func makeDelete(tracker: Tracker) {
        guard let trackerCD = trackersStore.extractTrackerById(id: tracker.id) else {
            return
        }
        self.deleteConfirmationDialog(tracker: trackerCD)
    }
}


extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 9 - 32) / 2, height: 148)
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
        store.searchText = ""
        store.isFiltered = false
        didUpdate()
        updatePlaceholderVisibility()
    }
}

extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            store.searchText = ""
            store.isFiltered = false
        } else {
            store.searchText = searchText
            isFiltered = true
        }
        didUpdate()
        updatePlaceholderVisibility()
        
    }
}

extension TrackersViewController: StoreDelegate {
    func didUpdate() {
        categories = prepareCategories(categories: store.categories, filter: store.trackersFilter)
        allCategories = categoriesStore.extractAllCategoriesAsArray()
        collectionView.reloadData()
    }
}

import UIKit

final class TrackersViewController: UIViewController {
    
    private var categories: [TrackerCategory] = []
    private var allCategories: [TrackerCategory]=[]
    private var currentDate: Date = Date()
    private let datePicker: UIDatePicker = UIDatePicker()
    private var searchText: String = ""
    private var isFiltered: Bool = false

    private var store = Store()

    
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
        store.delegate = self
        categories = store.categories
        allCategories = store.trackerCategoryStore.extractAllCategoriesAsArray()
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
        guard
            let indexPath = collectionView.indexPath(for: cell)
        else {
            assertionFailure("Can't find cell")
            return
        }
        let tracker = categories[indexPath.section].trackers[indexPath.row]
        guard let trackerCD = store.trackerStore.extractTrackerById(id: tracker.id) else {
            return
        }
        try? store.trackerRecordStore.addNewRecord(tracker: trackerCD, date: store.currentDate)
        didUpdate()
        updatePlaceholderVisibility()
    }
    
    @objc private func dateHandler(_ sender: UIDatePicker) {
        store.currentDate = sender.date
        didUpdate()
        updatePlaceholderVisibility()
    }


    func addNewTracker(newTracker: Tracker, categoryId: UUID) {
        guard let categoryCD = store.trackerCategoryStore.extractCategoryById(id: categoryId) else {
            return
        }
        try? store.trackerStore.addNewTracker(newTracker, category: categoryCD)
        self.didUpdate()
        self.updatePlaceholderVisibility()
    }

    //добавление трекера
    @objc
    private func addTracker() {
        let trackerSelect = TrackerSelectViewController(categories: allCategories, addingTrackerCompletion: addNewTracker, addingCategoryCompletion: addNewCategory)
        present(trackerSelect, animated: true)
    }


    func addNewCategory(newCategory: TrackerCategory) {
        do {
            try store.trackerCategoryStore.addNewCategory(newCategory)
        }
        catch {
            print(error)
        }
        self.didUpdate()
        self.updatePlaceholderVisibility()
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
        guard !searchText.isEmpty else {
            store.searchText = ""
            store.isFiltered = false
            didUpdate()
            updatePlaceholderVisibility()
            return
        }
        store.searchText = searchText
        isFiltered = true
        didUpdate()
        updatePlaceholderVisibility()
    }
}


extension TrackersViewController: StoreDelegate {
    func didUpdate() {
        categories = store.categories
        collectionView.reloadData()
    }
}

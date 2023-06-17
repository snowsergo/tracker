import UIKit

final class TrackersViewController: UIViewController {
//    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
//        <#code#>
//    }

    
    private var categories: [TrackerCategory] = []
    private var allCategories: [TrackerCategory]=[]
    private var currentDate: Date = Date()
    private let datePicker: UIDatePicker = UIDatePicker()
    private var searchText: String = ""
    private var isFiltered: Bool = false
    
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
    
    init(store: Store) {
        self.store = store
        categoriesStore = TrackerCategoryStore(store: store)
        trackersStore = TrackerStore(store: store)
        trackerRecordsStore = TrackerRecordStore(store: store)
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
        categories = store.categories
        allCategories = categoriesStore.extractAllCategoriesAsArray()
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

//    @objc func didLongPress(gesture: UILongPressGestureRecognizer) {
//          guard gesture.state == .began else { return }
//
//          // Получаем indexPath ячейки
//          guard
////            let collectionView = collectionView
//            
//                let indexPath = collectionView.indexPath(for: cell)
//          else { return }
//
//          // Создаем действия для меню
//          let action1 = UIAction(title: "Действие 1") { _ in
//              // Обработчик действия 1
//              print("1")
//          }
//          let action2 = UIAction(title: "Действие 2") { _ in
//              // Обработчик действия 2
//              print("2")
//          }
//          let menu = UIMenu(title: "", children: [action1, action2])
//
//          // Создаем конфигурацию контекстного меню и возвращаем ее
//          let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
//              return menu
//          }
//
//          // Отображаем контекстное меню
//          let menuController = UIMenuController.shared
//          menuController.showMenu(from: collectionView, rect: colorBackground.frame)
//      }
//    func didTapTrackerBackground(in cell: TrackerCollectionViewCell) {
//            guard let indexPath = collectionView.indexPath(for: cell) else {
//                return
//            }
//
//            let menuConfiguration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in
////                return UIMenu(title: "", children: [
////                    UIAction(title: "Bold") { [weak self] _ in
////                        self?.makeBold(indexPath: indexPath)
////                    },
////                    UIAction(title: "Italic") { [weak self] _ in
////                        self?.makeItalic(indexPath: indexPath)
////                    }
////                ])
//                let boldAction = UIAction(title: "Bold", image: UIImage(systemName: "bold")) { [weak self] _ in
//                        self?.makeBold(indexPath: indexPath)
//                    }
//                    let italicAction = UIAction(title: "Italic", image: UIImage(systemName: "italic")) { [weak self] _ in
//                        self?.makeItalic(indexPath: indexPath)
//                    }
//                    return UIMenu(title: "", children: [boldAction, italicAction])
//            })
//
//        let targetView = cell.backgroundColor // здесь должен быть ваш UIImageView
//            let contextMenu = UIMenuController.shared
//            contextMenu.showContextMenu(from: targetView, in: targetView)
//            contextMenu.menuItems = menuConfiguration.menuItems
//
//
//
//        }

//    // Функция обработки жеста нажатия для вызова контекстного меню
//       @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
//           guard gesture.state == .began else {
//               return
//           }
//           let touchPoint = gesture.location(in: collectionView)
//           if let indexPath = collectionView.indexPathForItem(at: touchPoint) {
//               let selectedTracker = categories[indexPath.section].trackers[indexPath.item]
//               let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
//                   let boldAction = UIAction(title: "Bold", image: UIImage(systemName: "bold")) { _ in
//                       self.makeBold(selectedTracker: selectedTracker)
//                   }
//                   let italicAction = UIAction(title: "Italic", image: UIImage(systemName: "italic")) { _ in
//                       self.makeItalic(selectedTracker: selectedTracker)
//                   }
//                   return UIMenu(title: "", children: [boldAction, italicAction])
//               })
//               let menu = UIMenu(title: "")
//               let cell = collectionView.cellForItem(at: indexPath)
//               let menuInteraction = UIContextMenuInteraction(delegate: self)
//               cell?.addInteraction(menuInteraction)
//               menuInteraction.updateVisibleMenu(with: configuration, from: cell?.contentView.bounds ?? CGRect.zero)
//           }
//       }
    func makeBold(selectedTracker: Tracker) {
          print("bold")
      }

      func makeItalic(selectedTracker: Tracker) {
          print("italic")
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
    
    //добавление трекера
    @objc
    private func addTracker() {
        let trackerSelect = TrackerSelectViewController(categories: allCategories, addingTrackerCompletion: addNewTracker, addingCategoryCompletion: addNewCategory)
        present(trackerSelect, animated: true)
    }
    
    
    func addNewCategory(newCategory: TrackerCategory) {
        categoriesStore.addNewCategory(newCategory)
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
//        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
//                cell.addGestureRecognizer(longPressGesture)
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
        let action1 = UIAction(title: "действие 1") { [weak self] _ in
            self?.makeBold(indexPath: indexPath)
        }
        let action2 = UIAction(title: "действие 2") { [weak self] _ in
            self?.makeItalic(indexPath: indexPath)
        }
        let menu = UIMenu(title: "", children: [action1, action2])
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in menu })
    }

    func makeBold(indexPath: IndexPath) {
        print("bold")
    }

    func makeItalic(indexPath: IndexPath) {
        print("italic")
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
        categories = store.categories
        allCategories = categoriesStore.extractAllCategoriesAsArray()
        collectionView.reloadData()
    }
}

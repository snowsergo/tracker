import UIKit

final class TrackerCreationViewController: UIViewController{
    private var isRegular: Bool
    private var categories: [TrackerCategory]
    private var selectedCategory: TrackerCategory?
    private var selectedEmoji: String?
    private var selectedColor: String?
    private var days: Set<WeekDay> = []
    private let completion: (Tracker, UUID) -> Void
    private let addingCategoryCompletion: (TrackerCategory) -> Void
    private let emojis = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶",
        "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]
    private let colors = [
        "#FD4C49",
        "#FF881E",
        "#007BFA",
        "#6E44FE",
        "#33CF69",
        "#E66DD4",
        "#F9D4D4",
        "#34A7FE",
        "#46E69D",
        "#35347C",
        "#FF674D",
        "#FF99CC",
        "#F6C48B",
        "#7994F5",
        "#832CF1",
        "#AD56DA",
        "#8D72E6",
        "#2FD058"
    ]
    
    private let emojiCollectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.keyboardDismissMode = .onDrag
        collectionView.contentInset = .init(top: 10, left: 0, bottom: 0, right: 0)
        
        collectionView.register(
            SubTableHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "emojiHeader"
        )
        
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: "emojiCell")
        return collectionView
    }()
    
    private let colorCollectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.keyboardDismissMode = .onDrag
        collectionView.contentInset = .init(top: 10, left: 0, bottom: 0, right: 0)
        
        collectionView.register(
            SubTableHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "colorHeader"
        )
        
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: "colorCell")
        return collectionView
    }()
    
    private var scrollView: UIScrollView = UIScrollView()
    
    init(categories: [TrackerCategory], isRegular: Bool, completion: @escaping (Tracker, UUID) -> Void, addingCategoryCompletion: @escaping (TrackerCategory) -> Void){
        self.categories = categories
        self.isRegular = isRegular
        self.completion = completion
        self.addingCategoryCompletion = addingCategoryCompletion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let labelView: UILabel = UILabel();
    private let textField: UITextField = UITextField()
    private let submitButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
    private let cancelButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupAppearance()
        addCategoryButton()
        if isRegular {
            addScheduleButton()
        }
        
        setupScrollView(isRegular: isRegular)
        setupEmojiCollectionView()
        setupColorCollectionView()
    }
    
    
    private func setupScrollView(isRegular: Bool) {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: isRegular ? scheduleButton.bottomAnchor : categoryButton.bottomAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -16),
        ])
    }
    
    private func setupAppearance() {
        
        labelView.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(labelView)
        view.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: labelView.bottomAnchor, constant: 50),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75)
        ])
        textField.placeholder = "Введите название трекера"
        textField.font = .asset(.ysDisplayRegular, size: 17)
        let paddingLeft = UIView(frame: .init(origin: .zero, size: .init(width: 16, height: 1)))
        textField.leftViewMode = .always
        textField.leftView = paddingLeft
        textField.clearButtonMode = .always
        textField.backgroundColor = .asset(.lightGrey).withAlphaComponent(0.3)
        textField.layer.cornerRadius = 10
        textField.layer.masksToBounds = true
        textField.addTarget(self, action: #selector(handleTextField), for: .allEditingEvents)
        
        view.addSubview(submitButton)
        view.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            labelView.topAnchor.constraint(equalTo: view.topAnchor, constant: 13),
            labelView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            submitButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            submitButton.heightAnchor.constraint(equalToConstant: 60),
            submitButton.widthAnchor.constraint(equalToConstant: 160)
        ])
        
        NSLayoutConstraint.activate([
            cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalToConstant: 160)
        ])
        
        labelView.text = isRegular ? "Новая привычка" : "Новое нерегулярное событие"
        labelView.font = .asset(.ysDisplayMedium, size: 16)
        submitButton.setTitle("Создать", for: .normal)
        submitButton.backgroundColor = .asset(.grey)
        submitButton.isEnabled = false
        submitButton.layer.cornerRadius = 16
        submitButton.addTarget(self, action: #selector(createTracker), for: .touchUpInside)
        submitButton.setTitleColor(.white, for: .normal)
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.asset(.red).cgColor
        cancelButton.setTitleColor(.asset(.red), for: .normal)
        cancelButton.layer.cornerRadius = 16
        cancelButton.addTarget(self, action: #selector(cancelCreation), for: .touchUpInside)
        
    }
    
    // настройка коллекции emoji
    private func setupEmojiCollectionView() {
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(emojiCollectionView)
        
        NSLayoutConstraint.activate([
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 220),
            emojiCollectionView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            emojiCollectionView.topAnchor.constraint(equalTo: scrollView.topAnchor)
        ])
        
    }
    
    // настройка коллекции color
    private func setupColorCollectionView() {
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(colorCollectionView)
        
        NSLayoutConstraint.activate([
            colorCollectionView.heightAnchor.constraint(equalToConstant: 220),
            colorCollectionView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            colorCollectionView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor),
            colorCollectionView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        ])
    }
    
    
    func updateButtonStatus() {
        let isScheduleOK = !isRegular  || !days.isEmpty
        let isInputOK = textField.text != nil && textField.text != ""
        let isCategoryOk = selectedCategory != nil
        let isEmojiOk = selectedEmoji != nil
        let isColorOk = selectedColor != nil
        if isScheduleOK && isInputOK && isCategoryOk && isEmojiOk && isColorOk {
            submitButton.isEnabled = true
            submitButton.backgroundColor = .asset(.black)
        } else {
            submitButton.isEnabled = false
            submitButton.backgroundColor = .asset(.grey)
        }
    }
    
    @objc
    private func cancelCreation() {
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
    
    @objc
    private func handleTextField() {
        updateButtonStatus()
    }
    
    private lazy var scheduleButton: ScheduleButton = {
        let button = ScheduleButton(title: "Расписание")
        button.addTarget(self, action: #selector(changeSchedule), for: .touchUpInside)
        return button
    }()
    private lazy var categoryButton: ScheduleButton = {
        let button = ScheduleButton(title: "Категория")
        button.addTarget(self, action: #selector(changeCategory), for: .touchUpInside)
        return button
    }()
    
    
    func addScheduleButton() {
        view.addSubview(scheduleButton)
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            scheduleButton.topAnchor.constraint(equalTo: categoryButton.bottomAnchor),
            scheduleButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            scheduleButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16)
        ])
    }
    
    func addCategoryButton() {
        view.addSubview(categoryButton)
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            categoryButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            categoryButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            categoryButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16)
        ])
    }
}

private extension TrackerCreationViewController {
    @objc func changeSchedule() {
        let scheduleCreation = ScheduleViewController(days: days) { [weak self] newDays in
            guard let self else { return }
            self.days = newDays
            let selectedDays = WeekDay.allCases
                .filter { newDays.contains($0) }
                .map { $0.shortLabel }
                .joined(separator: ", ")
            
            self.scheduleButton.setSubtitle(selectedDays.isEmpty ? nil : selectedDays)
            self.updateButtonStatus()
        }
        present(scheduleCreation, animated: true)
    }
    func selectCategory(selectedCategory: TrackerCategory){
        self.selectedCategory = selectedCategory
        self.categoryButton.setSubtitle(selectedCategory.label)
        self.updateButtonStatus()
    }
    
    func addCategory(newCategory: TrackerCategory)->Void {
        addingCategoryCompletion(newCategory);
        var categories = self.categories
        categories.append(newCategory)
        self.categories = categories
    }
    
    @objc func changeCategory() {
        let categoryViewController = CategoryViewController(categories: categories, selectedCategory: selectedCategory, days: days, completion: selectCategory, addingCategoryCompletion: addCategory)
        present(categoryViewController, animated: true)
    }
    
    @objc func createTracker() {
        guard let text = textField.text, let emoji = selectedEmoji, let color = selectedColor else {
            assertionFailure("Button should be disabled")
            return
        }
        
        let newTracker = Tracker(
            label: text,
            emoji: emoji,
            color: color,
            schedule: isRegular ? days : nil
        )
        guard let categoryId = selectedCategory?.id else { return }
        completion(newTracker, categoryId)
        
        
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
    
}

// collection view
extension TrackerCreationViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case emojiCollectionView : return emojis.count
        case colorCollectionView : return colors.count
        default : return 0
        }
    }
    
    //    ячейка
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath) as! EmojiCell
            cell.configure(emoji: emojis[indexPath.row], isSelected: false)
            return cell
        } else if collectionView == colorCollectionView  {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as! ColorCell
            cell.configure(color: colors[indexPath.row], isSelected: false)
            return cell
        }
        else {
            return UICollectionViewCell()
        }
    }
    
    //    хедер с названием суб-таблицы
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if collectionView == emojiCollectionView {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "emojiHeader", for: indexPath) as! SubTableHeaderView
            header.configure(label: "Emoji")
            return header
        } else if collectionView == colorCollectionView {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "colorHeader", for: indexPath) as! SubTableHeaderView
            header.configure(label: "Цвет")
            return header
        }
        else {
            return UICollectionViewCell()
        }
    }
}

// actions in tables
private extension TrackerCreationViewController {
    
    func tapEmoji(at path: IndexPath) {
        let newEmoji = emojis[path.row]
        guard selectedEmoji != newEmoji else { return }
        
        if
            let selectedEmoji,
            let index = emojis.firstIndex(of: selectedEmoji),
            let oldCell = emojiCollectionView.cellForItem(
                at: .init(row: index, section: path.section)
            ) as? EmojiCell {
            
            oldCell.configure(emoji: selectedEmoji, isSelected: false)
        }
        
        if let newCell = emojiCollectionView.cellForItem(at: path) as? EmojiCell {
            newCell.configure(emoji: newEmoji, isSelected: true)
        }
        
        selectedEmoji = newEmoji
    }
    
    func tapColor(at path: IndexPath) {
        let newColor = colors[path.row]
        guard selectedColor != newColor else { return }
        
        if
            let selectedColor,
            let index = colors.firstIndex(of: selectedColor),
            let oldCell = colorCollectionView.cellForItem(
                at: .init(row: index, section: path.section)
            ) as? ColorCell {
            
            oldCell.configure(color: selectedColor, isSelected: false)
        }
        
        if let newCell = colorCollectionView.cellForItem(at: path) as? ColorCell {
            newCell.configure(color: newColor, isSelected: true)
        }
        
        selectedColor = newColor
    }
}

extension TrackerCreationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.emojiCollectionView {
            tapEmoji(at: indexPath)
        } else if collectionView == self.colorCollectionView {
            tapColor(at: indexPath)
        }
        updateButtonStatus()
    }
}

extension TrackerCreationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 52)
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

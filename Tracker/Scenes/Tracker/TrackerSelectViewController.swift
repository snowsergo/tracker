import UIKit

final class TrackerSelectViewController: UIViewController {
    private var categories: [TrackerCategory]
    private let labelView: UILabel = UILabel();
    private let addingTrackerCompletion: (Tracker, UUID) -> Void
    private let addingCategoryCompletion: (TrackerCategory) -> Void
    
    init(categories: [TrackerCategory], addingTrackerCompletion: @escaping (Tracker, UUID) -> Void,  addingCategoryCompletion: @escaping (TrackerCategory) -> Void ) {
        self.categories = categories
        self.addingTrackerCompletion = addingTrackerCompletion
        self.addingCategoryCompletion = addingCategoryCompletion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
    }
    
    private lazy var addHabitButton: UIButton = {
        let button = YPButton(label: "Привычка")
        button.addTarget(self, action: #selector(addHabit), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var addIrregularButton: UIButton = {
        let button = YPButton(label: "Нерегулярные событие")
        button.addTarget(self, action: #selector(addIrregular), for: .touchUpInside)
        return button
    }()
    
    private func setupLayout() {
        labelView.translatesAutoresizingMaskIntoConstraints = false
        addHabitButton.translatesAutoresizingMaskIntoConstraints = false
        addIrregularButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        view.addSubview(labelView)
        view.addSubview(addHabitButton)
        view.addSubview(addIrregularButton)
        
        NSLayoutConstraint.activate([
            labelView.topAnchor.constraint(equalTo: view.topAnchor, constant: 13),
            labelView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            addHabitButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 330),
            addHabitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addHabitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addHabitButton.heightAnchor.constraint(equalToConstant: 60),
            addHabitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            addIrregularButton.topAnchor.constraint(equalTo: addHabitButton.bottomAnchor, constant: 16),
            addIrregularButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addIrregularButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addIrregularButton.heightAnchor.constraint(equalToConstant: 60),
            addIrregularButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        
        addHabitButton.backgroundColor = .black
        addHabitButton.setTitle("Привычка", for: .normal)
        addHabitButton.addTarget(self, action: #selector(addHabit), for: .touchUpInside)
        
        addIrregularButton.backgroundColor = .black
        addIrregularButton.setTitle("Нерегулярное событие", for: .normal)
        addIrregularButton.addTarget(self, action: #selector(addIrregular), for: .touchUpInside)
        
        
        labelView.text="Создание трекера"
        labelView.font = .asset(.ysDisplayMedium, size: 16)
    }
    
    func addCategory(newCategory: TrackerCategory)->Void {
        addingCategoryCompletion(newCategory);
        var categories = self.categories
        categories.append(newCategory)
        self.categories = categories
    }
    
    @objc
    private func addHabit() {
        let trackerCreation = TrackerCreationViewController(categories: categories, isRegular: true, completion: addingTrackerCompletion, addingCategoryCompletion: addCategory)
        present(trackerCreation, animated: true)
    }
    
    @objc
    private func addIrregular() {
        let trackerCreation = TrackerCreationViewController(categories: categories, isRegular: false, completion: addingTrackerCompletion, addingCategoryCompletion: addCategory)
        present(trackerCreation, animated: true)
    }
}


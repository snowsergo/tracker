import UIKit

final class CategoryViewController: UIViewController{
    private var categories: [TrackerCategory]
    private var selectedCategory: TrackerCategory?
    private var days: Set<WeekDay>
    private let completion: (TrackerCategory) -> Void
    private let addingCategoryCompletion: (TrackerCategory) -> Void
    private var items: [WeekDay] {WeekDay.allCases}
    
    init(categories: [TrackerCategory], selectedCategory: TrackerCategory?, days: Set<WeekDay>, completion: @escaping (TrackerCategory) -> Void, addingCategoryCompletion: @escaping (TrackerCategory) -> Void){
        self.categories  = categories
        self.selectedCategory = selectedCategory
        self.days = days
        self.completion  = completion
        self.addingCategoryCompletion  = addingCategoryCompletion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let labelView: UILabel = UILabel();
    private let submitButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupEntity()
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo:     view.bottomAnchor, constant: -150),
        ])
        
    }
    
    private func setupEntity() {
        labelView.translatesAutoresizingMaskIntoConstraints = false
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(labelView)
        view.addSubview(submitButton)
        
        NSLayoutConstraint.activate([
            labelView.topAnchor.constraint(equalTo: view.topAnchor, constant: 13),
            labelView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            submitButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            submitButton.heightAnchor.constraint(equalToConstant: 60),
        ])
        
        labelView.text = "Категория"
        labelView.font = .asset(.ysDisplayMedium, size: 16)
        submitButton.setTitle("Добавить категорию", for: .normal)
        submitButton.backgroundColor = .asset(.black)
        submitButton.layer.cornerRadius = 16
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.addTarget(self, action: #selector(addCategory), for: .touchUpInside)
    }
    
    @objc
    private func addCategory() {
        let categoryCreationViewController = CategoryCreationViewController() { [weak self] newCategory in
            guard let self else { return }
            self.selectedCategory = newCategory
            var categories = self.categories;
            categories.append(newCategory)
            self.categories = categories
            self.tableView.reloadData()
            self.completion(newCategory)
            self.addingCategoryCompletion(newCategory)
            self.dismiss(animated: false, completion: nil)
        }
        present(categoryCreationViewController, animated: true)
    }
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(CategoryViewCell.self, forCellReuseIdentifier: "cell")
        table.separatorInset = .init(top: 0, left: 32, bottom: 0, right: 32)
        table.separatorColor = .asset(.grey)
        table.delegate = self
        table.dataSource = self
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
}

// делегат
extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categories[indexPath.row]
        selectedCategory = category
        completion(category);
        self.tableView.reloadData()
        self.dismiss(animated: false, completion: nil)
    }
}

// датасорс
extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "cell", for: indexPath)
        
        guard let categoryCell = cell as? CategoryViewCell else {
            assertionFailure("Can't get cell for Schedule")
            return .init()
        }
        
        let category = categories[indexPath.row]
        
        categoryCell.configure(
            label: category.label,
            isOn: selectedCategory != nil ? true : false,
            type: indexPath.row == 0
            ? .first
            : indexPath.row == categories.count - 1
            ? .last
            : nil
        )
        
        return categoryCell
    }
}

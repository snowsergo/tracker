import UIKit

final class CategoryViewController: UIViewController{
    private var viewModel: CategoriesViewModel!
    private var selectedCategory: TrackerCategory?
    private var days: Set<WeekDay>
    private let completion: (TrackerCategory) -> Void
    private var items: [WeekDay] {WeekDay.allCases}
    
    init(categories: [TrackerCategory], selectedCategory: TrackerCategory?, days: Set<WeekDay>, completion: @escaping (TrackerCategory) -> Void){
        self.selectedCategory = selectedCategory
        self.days = days
        self.completion  = completion
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

        viewModel = CategoriesViewModel()
        viewModel.selectedCategory = selectedCategory
        viewModel.onChange = updateTable
        
    }

    func updateTable() {
        tableView.reloadData()
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
        let categoryCreationViewController = CategoryCreationViewController(categories: viewModel.categories) { [weak self] newCategory in
            guard let self else { return }
            self.viewModel.addCategory(newCategory: newCategory)
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
        let category = viewModel.categories[indexPath.row]
        viewModel.selectedCategory = category
        completion(category);
        self.tableView.reloadData()
        self.dismiss(animated: false, completion: nil)
    }
}

// датасорс
extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "cell", for: indexPath)
        
        guard let categoryCell = cell as? CategoryViewCell else {
            assertionFailure("Can't get cell for Schedule")
            return .init()
        }

        var type: CornerCellType? = nil
        if  indexPath.row == 0 {
            type = CornerCellType.first
        } else if indexPath.row == viewModel.categories.count - 1 {
            type = CornerCellType.last
        }
        
        let category = viewModel.categories[indexPath.row]
        
        categoryCell.configure(
            label: category.label,
            isOn: viewModel.selectedCategory?.id == category.id ? true : false,
            type: type
        )
        
        return categoryCell
    }
}

import UIKit

final class ScheduleViewController: UIViewController{
    private var days: Set<WeekDay>
    private let completion: (Set<WeekDay>) -> Void
    private var items: [WeekDay] {WeekDay.allCases}

    init(days: Set<WeekDay>, completion: @escaping (Set<WeekDay>) -> Void){
        self.days = days
        self.completion  = completion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let labelView: UILabel = UILabel();
//    private let textField: UITextField = UITextField(frame: <#T##CGRect#>)
//    private let scheduleButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
    private let submitButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
//    private let cancelButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))

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
//        tableView.backgroundColor = .asset(.red)
//        print(items)

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


        labelView.text = "Расписание"
        submitButton.setTitle("Готово", for: .normal)
        submitButton.backgroundColor = .asset(.black)
        submitButton.layer.cornerRadius = 16
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.addTarget(self, action: #selector(addSchedule), for: .touchUpInside)


    }

    @objc
    private func addSchedule() {
//        print("addSchedule")
        completion(days)
        self.dismiss(animated: false, completion: nil)
        }

    private lazy var tableView: UITableView = {
        let table = UITableView()

        table.register(ScheduleViewCell.self, forCellReuseIdentifier: "cell")

        table.separatorInset = .init(top: 0, left: 32, bottom: 0, right: 32)
        table.separatorColor = .asset(.grey)

        table.delegate = self
        table.dataSource = self

        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
}

// делегат
extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? ScheduleViewCell

        let day = items[indexPath.row]
        let isOn = days.contains(day)

        if isOn {
            days.remove(day)
        } else {
            days.insert(day)
        }

        cell?.setOn(!isOn)
    }
}

// MARK: - датасорс

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "cell", for: indexPath)

        guard let scheduleCell = cell as? ScheduleViewCell else {
            assertionFailure("Can't get cell for Schedule")
            return .init()
        }

        let day = items[indexPath.row]

        scheduleCell.configure(
            label: day.label,
            isOn: days.contains(day),
            type: indexPath.row == 0
            ? .first
            : indexPath.row == items.count - 1
            ? .last
            : nil
        )

        return scheduleCell
    }
}

import UIKit

final class TrackerSelectViewController: UIViewController {
    private let labelView: UILabel = UILabel();
    private let completion: (Tracker) -> Void
    private let addHabbitButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
    private let addIrregularButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))

    init(completion: @escaping (Tracker) -> Void) {
//        super.init()
        self.completion = completion
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

    private func setupLayout() {
        labelView.translatesAutoresizingMaskIntoConstraints = false
        addHabbitButton.translatesAutoresizingMaskIntoConstraints = false
        addIrregularButton.translatesAutoresizingMaskIntoConstraints = false


        view.addSubview(labelView)
        view.addSubview(addHabbitButton)
        view.addSubview(addIrregularButton)

        NSLayoutConstraint.activate([
            labelView.topAnchor.constraint(equalTo: view.topAnchor, constant: 13),
//            labelView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            labelView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        NSLayoutConstraint.activate([
            addHabbitButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 330),
//            addHabbitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addHabbitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addHabbitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addHabbitButton.heightAnchor.constraint(equalToConstant: 60),
            addHabbitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        NSLayoutConstraint.activate([
            addIrregularButton.topAnchor.constraint(equalTo: addHabbitButton.bottomAnchor, constant: 16),
            addIrregularButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addIrregularButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addIrregularButton.heightAnchor.constraint(equalToConstant: 60),
            addIrregularButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
//            addIrregularButton.widthAnchor.constraint(equalToConstant: <#T##CGFloat#>)
        ])


        addHabbitButton.backgroundColor = .black
        addHabbitButton.setTitle("Привычка", for: .normal)
        addHabbitButton.addTarget(self, action: #selector(addHabbit), for: .touchUpInside)

        addIrregularButton.backgroundColor = .black
        addIrregularButton.setTitle("Нерегулярное событие", for: .normal)
        addIrregularButton.addTarget(self, action: #selector(addIrregular), for: .touchUpInside)


        labelView.text="Создание трекера"
    }

    @objc
    private func addHabbit() {
//        print("addHabbit")
        let trackerCreation = TrackerCreationViewController(isRegular: true, completion: completion)
        present(trackerCreation, animated: true)
        }

    @objc
    private func addIrregular() {
//        print("add irregular")
        let trackerCreation = TrackerCreationViewController(isRegular: false, completion: completion)
        present(trackerCreation, animated: true)
        }
    }


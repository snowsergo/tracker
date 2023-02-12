import UIKit

final class TrackerCreationViewController: UIViewController{
    private var isRegular: Bool
//    private let onCreate: (Tracker, TrackerCategory) -> Void
    private var days: Set<WeekDay> = []
//    private let categories: [TrackerCategory]
    private let completion: (Tracker) -> Void
    private let emojis = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶",
        "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]

    init(isRegular: Bool, completion: @escaping (Tracker) -> Void){
        self.isRegular = isRegular
//        self.categories = categories
//        self.onCreate = onCreate
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let labelView: UILabel = UILabel();
    private let textField: UITextField = UITextField()
//    private let scheduleButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
    private let submitButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
    private let cancelButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupEntity()
//        setupScheduleButton()
        if isRegular {
            addScheduleButton()
        }

    }

    private func setupEntity() {

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
        textField.clearButtonMode = .always
        textField.backgroundColor = .asset(.lightGrey).withAlphaComponent(0.3)
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
        submitButton.setTitle("Создать", for: .normal)
        submitButton.backgroundColor = .asset(.grey)
        submitButton.layer.cornerRadius = 16
//        submitButton.layer.borderColor = CG.asset(.black)
        submitButton.addTarget(self, action: #selector(createTracker), for: .touchUpInside)
        submitButton.setTitleColor(.white, for: .normal)
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.asset(.red).cgColor
        cancelButton.setTitleColor(.asset(.red), for: .normal)
        cancelButton.layer.cornerRadius = 16
//        cancelButton
        cancelButton.addTarget(self, action: #selector(cancelCreation), for: .touchUpInside)

    }
    @objc
    private func cancelCreation() {
//        print("cancelCreation")
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
        }

    @objc
    private func handleTextField() {
//        print("handleTextField")
        }


    private lazy var scheduleButton: ScheduleButton = {
        let button = ScheduleButton(title: "Расписание")
        button.addTarget(self, action: #selector(changeSchedule), for: .touchUpInside)
        return button
    }()

    func addScheduleButton() {
        view.addSubview(scheduleButton)
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            scheduleButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            scheduleButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            scheduleButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16)
        ])
    }


}

private extension TrackerCreationViewController {
    @objc func changeSchedule() {
//        print("changeSchedule")
        let scheduleCreation = ScheduleViewController(days: days) { [weak self] newDays in
            guard let self else { return }
            self.days = newDays
            let selectedDays = WeekDay.allCases
                .filter { newDays.contains($0) }
                .map { $0.shortLabel }
                .joined(separator: ", ")

            self.scheduleButton.setSubtitle(selectedDays.isEmpty ? nil : selectedDays)
        }
        present(scheduleCreation, animated: true)
//        updateButtonStatus()
//        navigateTo(scheduleVC)
    }

    @objc func createTracker() {
        guard let text = textField.text else {
            assertionFailure("Button should be disabled")
            return
        }

        let newTracker = Tracker(
            label: text,
            emoji: emojis.randomElement()!,
            color: TrackerColor.allCases.randomElement()!,
            schedule: isRegular ? days : nil
        )
//        print("NewTracker = ", newTracker)
//        onCreate(newTracker, categories[0])
        completion(newTracker)

//        dismiss(animated: true)
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
}

import UIKit

final class CategoryCreationViewController: UIViewController{
    weak var delegate: TrackersViewController?
    private let completion: (TrackerCategory) -> Void

    init(completion: @escaping (TrackerCategory) -> Void){
        self.completion = completion
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
        textField.placeholder = "Введите название категории"
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

        labelView.text = "Новая категория"
        labelView.font = .asset(.ysDisplayMedium, size: 16)
        submitButton.setTitle("Создать", for: .normal)
        submitButton.backgroundColor = .asset(.grey)
        submitButton.isEnabled = false
        submitButton.layer.cornerRadius = 16
        submitButton.addTarget(self, action: #selector(createCategory), for: .touchUpInside)
        submitButton.setTitleColor(.white, for: .normal)
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.asset(.red).cgColor
        cancelButton.setTitleColor(.asset(.red), for: .normal)
        cancelButton.layer.cornerRadius = 16
        cancelButton.addTarget(self, action: #selector(cancelCreation), for: .touchUpInside)

    }

    func updateButtonStatus() {
        let isInputOK = textField.text != nil && textField.text != ""
        if isInputOK {
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

}

private extension CategoryCreationViewController {
    @objc func createCategory() {
        guard let text = textField.text else {
            assertionFailure("Button should be disabled")
            return
        }

        let newCategory = TrackerCategory(
            label: text,
            trackers: []
        )
        self.delegate?.addNewCategory(newCategory: newCategory)
        completion(newCategory)
//        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
}

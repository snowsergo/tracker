import UIKit

final class ScheduleButton: UIButton {
    init(title: String, subtitle: String? = nil) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        titleView.text = title

        backgroundColor = .asset(.lightGrey).withAlphaComponent(0.3)

        layer.cornerRadius = 10
        layer.masksToBounds = true

        stackView.addArrangedSubview(titleView)

        if let subtitle {
            subtitleView.text = subtitle
            stackView.addArrangedSubview(subtitleView)
        }

        addSubview(stackView)
        addSubview(iconView)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 75),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }

    func setSubtitle(_ subtitle: String? = nil) {
        subtitleView.text = subtitle

        if subtitle != nil, stackView.arrangedSubviews.count == 1 {
            stackView.addArrangedSubview(subtitleView)
        } else if subtitle == nil {
            stackView.removeArrangedSubview(subtitleView)
        }
    }

    private lazy var titleView: UILabel = {
        let label = UILabel()

//        label.font = .asset(.ysDisplayRegular, size: 17)
        label.textColor = .asset(.black)

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var subtitleView: UILabel = {
        let label = UILabel()

//        label.font = .asset(.ysDisplayRegular, size: 17)
        label.textColor = .asset(.grey)

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var iconView: UIImageView = {
        let view = UIImageView()

        view.image = UIImage(named: "arrow")?.withTintColor(.asset(.grey))
//        view.tintColor = .asset(.gray)

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var stackView: UIStackView = {
        let vStack = UIStackView()

        vStack.axis = .vertical
        vStack.spacing = 2
        vStack.alignment = .leading

        vStack.translatesAutoresizingMaskIntoConstraints = false
        return vStack
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

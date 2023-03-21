import UIKit

final class CategoryViewCell: UITableViewCell {
    var isOn: Bool = false

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var iconView: UIImageView = {
        let view = UIImageView()

        view.image = UIImage(named: "check")
        view.tintColor = .asset(.blue)

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    func configure(label: String? = nil, isOn: Bool = false, type: CornerCellType? = nil) {
        labelView.text = label

        self.isOn = isOn

        backView.layer.maskedCorners = type == .first
            ? [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            : type == .last
                ? [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                : []

        if type == .last {
            separatorInset = .init(top: 0, left: .infinity, bottom: 0, right: 0)
        }
    }

    override func prepareForReuse() {
        configure()
    }

    private lazy var labelView: UILabel = {
        let label = UILabel()

        label.font = .asset(.ysDisplayRegular, size: 17)
        label.textColor = .asset(.black)

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var backView: UIView = {
        let view = UIView()

        view.backgroundColor = .asset(.lightGrey).withAlphaComponent(0.3)

        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.layer.maskedCorners = []

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
}

// MARK: - Appearance

private extension CategoryViewCell {

    func setupAppearance() {
        backgroundColor = .clear
        selectionStyle = .none

        addSubview(labelView)
        insertSubview(backView, at: 0)

        NSLayoutConstraint.activate([
            backView.topAnchor.constraint(equalTo: topAnchor),
            backView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            backView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            backView.bottomAnchor.constraint(equalTo: bottomAnchor),
            labelView.centerYAnchor.constraint(equalTo: centerYAnchor),
            labelView.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 16),
            labelView.topAnchor.constraint(equalTo: topAnchor, constant: 26.5),
            labelView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -26.5),
        ])

        if (self.isOn){
            addSubview(iconView)
            NSLayoutConstraint.activate([
                iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
                iconView.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -16)
            ])
        }
    }
}

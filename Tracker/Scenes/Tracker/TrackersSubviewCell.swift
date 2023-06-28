import UIKit

final class TrackersSubviewCell: UIView {
    // MARK: - Properties
    var colorBackground: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .asset(.ysDisplayMedium, size: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .asset(.contrast)
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var trackerLabel: UILabel = {
       let label = UILabel()
       label.numberOfLines = 2
       label.font = .asset(.ysDisplayMedium, size: 12)
       label.textColor = .asset(.white)
       label.translatesAutoresizingMaskIntoConstraints = false
       return label
   }()


    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods
    func setupView(tracker: Tracker) {
        trackerLabel.text = tracker.label
        emojiLabel.text = tracker.emoji
        colorBackground.backgroundColor = UIColor(hex: tracker.color + "ff")
    }

    private func layout() {
        [emojiLabel, trackerLabel].forEach { colorBackground.addSubview($0) }
        [colorBackground].forEach { addSubview($0) }

        NSLayoutConstraint.activate([
            colorBackground.topAnchor.constraint(equalTo: topAnchor),
            colorBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            colorBackground.trailingAnchor.constraint(equalTo: trailingAnchor),
            colorBackground.bottomAnchor.constraint(equalTo: bottomAnchor),

            emojiLabel.leadingAnchor.constraint(equalTo: colorBackground.leadingAnchor, constant: 12),
            emojiLabel.topAnchor.constraint(equalTo: colorBackground.topAnchor, constant: 12),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),

            trackerLabel.leadingAnchor.constraint(equalTo: colorBackground.leadingAnchor, constant: 12),
            trackerLabel.trailingAnchor.constraint(equalTo: colorBackground.trailingAnchor, constant: -12),
            trackerLabel.bottomAnchor.constraint(equalTo: colorBackground.bottomAnchor, constant: -12),
        ])
    }
}

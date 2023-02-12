//import UIKit
//
//final class LetterCollectionViewCell: UICollectionViewCell {
//    // Здесь будет код нашей ячейки
//    let titleLabel = UILabel()
//
//    override init(frame: CGRect) {                  // 1
//        super.init(frame: frame)                    // 2
//
//        contentView.addSubview(titleLabel)          // 3
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false    // 4
//
//        NSLayoutConstraint.activate([                                    // 5
//            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
//                                    ])
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}

import UIKit

final class LetterCollectionViewCell: UICollectionViewCell {
    let titleLabel: UILabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

import UIKit

final class EmojiCell: UICollectionViewCell {
    private lazy var background: UIView = {
        let view = UIView()
        
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.backgroundColor = .asset(.white)
        
        return view
    }()
    
    private lazy var labelView: UILabel = {
        let label = UILabel()
        
        label.font = .asset(.ysDisplayBold, size: 32)
        label.textAlignment = .center
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(background)
        addSubview(labelView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        background.frame = bounds
        labelView.frame = bounds
    }
    
    func configure(emoji: String?, isSelected: Bool = false) {
        labelView.text = emoji
        
        if isSelected {
            background.backgroundColor = .asset(.lightGrey)
        } else {
            background.backgroundColor = .asset(.white)
        }
    }
    
    override func prepareForReuse() {
        configure(emoji: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

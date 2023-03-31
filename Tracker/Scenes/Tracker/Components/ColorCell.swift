import UIKit

final class ColorCell: UICollectionViewCell {
    private lazy var background: UIView = {
        let view = UIView()
        
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.asset(.black).withAlphaComponent(0.3).cgColor
        
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        
        return view
    }()
    
    private lazy var colorView: UIView = {
        let view = UIView()
        
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(background)
        addSubview(colorView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        background.frame = bounds
        colorView.frame = bounds.insetBy(dx: 6, dy: 6)
    }
    
    func configure(color: String?, isSelected: Bool = false) {
        guard let color = color else {return}
        colorView.backgroundColor = UIColor(hex: color + "ff")
        
        if isSelected {
            background.layer.borderWidth = 3
            
        } else {
            background.layer.borderWidth = 0
        }
    }
    
    override func prepareForReuse() {
        configure(color: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//  Copyright Mux Inc. 2020.

import UIKit
import Hue

public class MuxButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    fileprivate func setup() {
        self.setTitleColor(UIColor.white, for: .normal)
        self.layer.cornerRadius = self.frame.height * 0.25
        self.backgroundColor = UIColor(hex: "#fb2490")
    }
    
    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor(hex: "#fb2490").alpha(0.7) : UIColor(hex: "#fb2490")
        }
    }
}

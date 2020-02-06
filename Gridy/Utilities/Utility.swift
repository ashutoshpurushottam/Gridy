//
//  GridyCreation.swift
//  Gridy
//

import UIKit

class Creation {
    var image: UIImage
    static var defaultImage : UIImage {
        return UIImage.init(named: "Placeholder")!
    }
    init() {
        image = Creation.defaultImage
    }
}

class RoundCorner: UIView {
    override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
    }
}

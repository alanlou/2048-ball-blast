//
//  BallItem.swift
//  Bouncing
//
//  Created by Alan Lou on 12/17/17.
//  Copyright © 2017 Rawwr Studios. All rights reserved.
//

import UIKit

class BallItem: NSObject, NSCoding {
    
    let identifier: String
    let color: UIColor
    var isBought: Bool
    
    init(identifier: String, color: UIColor, isBought: Bool) {
        self.identifier = identifier
        self.color = color
        self.isBought = isBought
    }
    required init(coder decoder: NSCoder) {
        self.identifier = decoder.decodeObject(forKey: "identifier") as? String ?? ""
        self.color = decoder.decodeObject(forKey: "color") as? UIColor ?? ColorCategory.getLineColor()
        self.isBought = decoder.decodeBool(forKey: "isBought")
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(identifier, forKey: "identifier")
        coder.encode(color, forKey: "color")
        coder.encode(isBought, forKey: "isBought")
    }
}

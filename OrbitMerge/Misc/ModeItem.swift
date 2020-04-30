//
//  BallItem.swift
//  OrbitMerge
//
//  Created by Alan Lou on 12/17/17.
//  Copyright © 2017 Rawwr Studios. All rights reserved.
//

import UIKit

class ModeItem: NSObject, NSCoding {
    
    let identifier: String
    var isBought: Bool
    
    init(identifier: String, isBought: Bool) {
        self.identifier = identifier
        self.isBought = isBought
    }
    
    required init(coder decoder: NSCoder) {
        self.identifier = decoder.decodeObject(forKey: "identifier") as? String ?? ""
        self.isBought = decoder.decodeBool(forKey: "isBought")
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(identifier, forKey: "identifier")
        coder.encode(isBought, forKey: "isBought")
    }
}

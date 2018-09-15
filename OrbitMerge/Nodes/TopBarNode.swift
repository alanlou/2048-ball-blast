//
//  TopBarNode.swift
//  OrbitMerge
//
//  Created by Alan Lou on 9/9/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import SpriteKit

class TopBarNode: SKSpriteNode {
    
    //MARK:- Initialization
    init(color: SKColor, width: CGFloat, height: CGFloat) {
        let textureSize = CGSize(width: width, height: height)
        super.init(texture: nil, color: .clear, size: textureSize)
        self.name = "topbarnode"
        self.color = color
        self.colorBlendFactor = 1.0
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Helper Functions
    func changeColor(to color: SKColor) {
        self.color = color
        self.colorBlendFactor = 1.0
    }
}



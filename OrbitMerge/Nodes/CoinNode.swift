//
//  CoinNode.swift
//  Bouncing
//
//  Created by Alan Lou on 12/2/17.
//  Copyright © 2017 Rawwr Studios. All rights reserved.
//

import SpriteKit

class CoinNode: SKSpriteNode {
    
    //MARK:- Initialization
    init(color: SKColor, width: CGFloat) {
        let texture = SKTexture(imageNamed: "CoinNode")
        let textureSize = CGSize(width: width, height: width)
        super.init(texture: texture, color: .clear, size: textureSize)
        self.name = "coinnode"
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



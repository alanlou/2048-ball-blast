//
//  CoinNode.swift
//  OrbitMerge
//
//  Created by Alan Lou on 12/2/17.
//  Copyright © 2017 Rawwr Studios. All rights reserved.
//

import SpriteKit

class CoinNode: SKSpriteNode {
    
    //MARK:- Initialization
    init(width: CGFloat) {
        let texture = SKTexture(imageNamed: "Coin")
        let textureSize = CGSize(width: width, height: width)
        super.init(texture: texture, color: .clear, size: textureSize)
        self.name = "coinnode"
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



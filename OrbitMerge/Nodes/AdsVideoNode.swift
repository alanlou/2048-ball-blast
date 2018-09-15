//
//  AdsVideoNode.swift
//  Bouncing
//
//  Created by Alan Lou on 2/12/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import SpriteKit

class AdsVideoNode: SKSpriteNode {
    
    //MARK:- Initialization
    init(color: SKColor, height: CGFloat) {
        let texture = SKTexture(imageNamed: "AdsVideo")
        let textureSize = CGSize(width: height*texture.size().width/texture.size().height, height: height)
        super.init(texture: texture, color: .clear, size: textureSize)
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
    
    func getColor() -> SKColor {
        return self.color
    }
}



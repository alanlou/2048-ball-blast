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
    init(width: CGFloat) {
        let texture = SKTexture(imageNamed: "TopBar")
        let textureSize = CGSize(width: width, height:texture.size().height*width/texture.size().width)
        super.init(texture: texture, color: .clear, size: textureSize)
        self.name = "topbarnode"
        self.color = ColorCategory.getBarTopColor()
        self.colorBlendFactor = 1.0
        self.anchorPoint = CGPoint(x:0.5, y:1.0)
        
        // add shadow
        let shadow = ZLSpriteNode(width: width, image: "TopBar", color: ColorCategory.getBarBottomColor())
        shadow.position = CGPoint(x:0.0, y:-self.size.height*0.59)
        shadow.zPosition = -100
        self.addChild(shadow)
        
        // add shadow back
        let shadowback = ZLSpriteNode(width: width, image: "TopBarBack", color: ColorCategory.getBackgroundColor())
        shadowback.position = CGPoint(x:0.0, y:-self.size.height*0.59)
        shadowback.zPosition = -50
        self.addChild(shadowback)
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



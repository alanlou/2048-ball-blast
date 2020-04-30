//
//  ZLSpriteNode.swift
//  OrbitMerge
//
//  Created by Alan Lou on 8/4/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import SpriteKit

class ZLSpriteNode: SKSpriteNode {
    
    //MARK:- Initialization
    init(width: CGFloat, image: String) {
        let texture = SKTexture(imageNamed: image)
        let textureSize = CGSize(width: width, height:texture.size().height*width/texture.size().width)
        super.init(texture: texture, color: .clear, size: textureSize)
    }
    
    init(height: CGFloat, image: String) {
        let texture = SKTexture(imageNamed: image)
        let textureSize = CGSize(width: texture.size().width*height/texture.size().height, height:height)
        super.init(texture: texture, color: .clear, size: textureSize)
    }
    
    convenience init(width: CGFloat, image: String, color: SKColor) {
        self.init(width: width, image: image)
        self.color = color
        self.colorBlendFactor = 1.0
    }
    
    convenience init(height: CGFloat, image: String, color: SKColor) {
        self.init(height: height, image: image)
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

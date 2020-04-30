//
//  BallNode.swift
//  OrbitMerge
//
//  Created by Alan Lou on 7/12/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import SpriteKit

class BallNode: SKSpriteNode {
    
    private let index: Int
    private var initRotationAngle: CGFloat = 0.0
    private var indexMessageNode: MessageNode
    
    //MARK:- Initialization
    init(width: CGFloat, index: Int) {
        self.index = index
        let texture = SKTexture(imageNamed: "Ball")
        let textureSize = CGSize(width: width, height:width)
        let fillNum = pow(2,index)
        indexMessageNode = MessageNode(message: "\(fillNum)")
        super.init(texture: texture, color: .clear, size: textureSize)
        self.name = "ball"
        self.color = ColorCategory.getBallColor(index: index)
        self.colorBlendFactor = 1.0
        
        // add message node
        var messageHeight = width*0.44
        if fillNum >= 100, fillNum < 1000 {
            messageHeight = width*0.47
        } else if fillNum >= 100 {
            messageHeight = width*0.50
        }
        let messageWidth = messageHeight*sqrt(3.0)
        
        let messageFrame = CGRect(x: -messageWidth*0.5,
                                  y: -messageHeight*0.5,
                                  width: messageWidth,
                                  height: messageHeight)
        //debugDrawArea(rect: messageFrame)
        indexMessageNode.adjustLabelFontSizeToFitRect(rect: CGRect(x: messageFrame.minX, y: messageFrame.minY, width: messageFrame.width, height: messageFrame.height))
        indexMessageNode.setHorizontalAlignment(mode: .center)
        indexMessageNode.setFontColor(color: .white)
        self.addChild(indexMessageNode)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Helper Functions
    func getIndex() -> Int {
        return self.index
    }
    
    func getScore() -> Int {
        return (pow(2,index) as NSDecimalNumber).intValue
    }
    
    func getColor() -> SKColor {
        return self.color
    }
    
    func setRotationAngle(to rotationAngle: CGFloat) {
        self.initRotationAngle = rotationAngle.smallRotationAngle
    }
    
    func getRotationAngle() -> CGFloat {
        return self.initRotationAngle
    }
    
    func changeColor(to color: SKColor) {
        self.color = color
    }
    
    func debugDrawArea(rect drawRect: CGRect) {
        let shape = SKShapeNode(rect: drawRect)
        shape.strokeColor = SKColor.red
        shape.lineWidth = 2.0
        self.addChild(shape)
    }
}

//
//  StoreItem.swift
//  Bouncing
//
//  Created by Alan Lou on 2/13/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import SpriteKit

protocol StoreItemDelegate: NSObjectProtocol {
    func ballWasSelected(sender: StoreItem)
}

class StoreItem: SKSpriteNode {
    
    weak var storeItemDelegate: StoreItemDelegate?
    let ballNode: SKSpriteNode
    
    var identifier: String = ""
    var thisBallColor: UIColor = ColorCategory.InitialBallColor
    var isThisBought: Bool = false
    var isAnimating: Bool = false
    
    let ballWidth: CGFloat
    let cellSize: CGSize
    
    //MARK:- Initialization
    init(color: SKColor, frameSize: CGSize, ballWidth: CGFloat) {
        self.ballWidth =  ballWidth
        cellSize = frameSize
        ballNode = SKSpriteNode(texture: SKTexture(imageNamed: "Ball"), color: .clear, size: CGSize(width:ballWidth, height:ballWidth))
        super.init(texture: nil, color: color, size: frameSize)
        self.isUserInteractionEnabled = false
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Helper Functions
    func setupStoreItem(as identifier: String) {
        self.identifier = identifier
        
        // error case
        if  UserDefaults.standard.object(forKey: identifier) == nil {
            return
        }
        
        let decoded  = UserDefaults.standard.object(forKey: identifier) as! Data
        let theBallItem = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! BallItem
        thisBallColor = theBallItem.color
        isThisBought = theBallItem.isBought
        
        
        if isThisBought {
            // clear content view first (in case there's lock view in place)
            self.removeAllChildren()
            
            ballNode.colorBlendFactor = 1.0
            ballNode.color = thisBallColor
            ballNode.position = CGPoint(x:0.0, y:0.0)
            self.addChild(ballNode)
            
            return
        }
        
        // Facebook -> 3
        if identifier == "Ball3" {
            // Set facebook node
            let lockNode = SKSpriteNode(texture: SKTexture(imageNamed: "Facebook"), color: .clear, size: CGSize(width:ballWidth*1.8, height:ballWidth*1.7))
            lockNode.position = CGPoint(x:0.0, y:lockNode.size.height/2)
            lockNode.color = .white
            lockNode.colorBlendFactor = 1.0
            self.addChild(lockNode)
            
            // Add Coin Node & label
            let coinNumberNode = MessageNode(message: "FREE!")
            coinNumberNode.setFontColor(color: .white)
            let coinNumberNodeWidth = cellSize.width*0.6
            let coinNumberNodeHeight = ballWidth+4
            let coinNumberNodeFrame = CGRect(x: -cellSize.width*0.30,
                                             y: -cellSize.height*0.2-coinNumberNodeHeight/2,
                                             width: coinNumberNodeWidth,
                                             height: coinNumberNodeHeight)
            coinNumberNode.adjustLabelFontSizeToFitRect(rect: coinNumberNodeFrame)
            coinNumberNode.setHorizontalAlignment(mode: SKLabelHorizontalAlignmentMode.center)
            //debugDrawArea(rect: coinNumberNodeFrame)
            self.addChild(coinNumberNode)
            return
        }
        
        // Twitter -> 4
        if identifier == "Ball4" {
            // Set twitter node
            let lockNode = SKSpriteNode(texture: SKTexture(imageNamed: "Twitter"), color: .clear, size: CGSize(width:ballWidth*1.9, height:ballWidth*1.8))
            lockNode.position = CGPoint(x:0.0, y:lockNode.size.height/2)
            lockNode.color = .white
            lockNode.colorBlendFactor = 1.0
            self.addChild(lockNode)
            
            // Add Coin Node & label
            let coinNumberNode = MessageNode(message: "FREE!")
            coinNumberNode.setFontColor(color: .white)
            let coinNumberNodeWidth = cellSize.width*0.6
            let coinNumberNodeHeight = ballWidth+4
            let coinNumberNodeFrame = CGRect(x: -cellSize.width*0.30,
                                             y: -cellSize.height*0.2-coinNumberNodeHeight/2,
                                             width: coinNumberNodeWidth,
                                             height: coinNumberNodeHeight)
            coinNumberNode.adjustLabelFontSizeToFitRect(rect: coinNumberNodeFrame)
            coinNumberNode.setHorizontalAlignment(mode: SKLabelHorizontalAlignmentMode.center)
            //debugDrawArea(rect: coinNumberNodeFrame)
            self.addChild(coinNumberNode)
            return
        }
        
        // otherwise, still locked
        // Set lock view
        let lockNode = SKSpriteNode(texture: SKTexture(imageNamed: "Lock"), color: .clear, size: CGSize(width:ballWidth*2.0, height:ballWidth*1.7))
        lockNode.color = .white
        lockNode.colorBlendFactor = 1.0
        lockNode.position = CGPoint(x:0.0, y:lockNode.size.height/2)
        self.addChild(lockNode)
        
        // Add Coin Node & label
        let coinNode = CoinNode(color: ColorCategory.InitialBallColor, width: ballWidth)
        coinNode.anchorPoint = CGPoint(x:0.0, y:0.5)
        coinNode.position = CGPoint(x: cellSize.width*0.15, y:-cellSize.height*0.2)
        self.addChild(coinNode)
        
        let coinNumber = 100
        let coinNumberNode = MessageNode(message: "\(coinNumber)")
        coinNumberNode.setFontColor(color: .white)
        let coinNumberNodeWidth = cellSize.width*0.55
        let coinNumberNodeHeight = coinNode.size.height+4
        let coinNumberNodeFrame = CGRect(x: -cellSize.width*0.45,
                                         y: -cellSize.height*0.2-coinNumberNodeHeight/2,
                                         width: coinNumberNodeWidth,
                                         height: coinNumberNodeHeight)
        coinNumberNode.adjustLabelFontSizeToFitRect(rect: coinNumberNodeFrame)
        coinNumberNode.setHorizontalAlignment(mode: SKLabelHorizontalAlignmentMode.right)
        //debugDrawArea(rect: coinNumberNodeFrame)
        self.addChild(coinNumberNode)
    }
    
    func setFrameToThisItem() {
        isAnimating = true
        // animate
        let wait = SKAction.wait(forDuration: 1.0)
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.4)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
        scaleUp.timingMode = .easeOut
        scaleDown.timingMode = .easeOut
        let scaleAction = SKAction.sequence([wait,scaleUp,scaleDown])
        
        ballNode.run(SKAction.repeatForever(scaleAction))
    }
    
    // MARK:- Helper Function
    func getTouched() {
        if let storeItemDelegate = storeItemDelegate {
            storeItemDelegate.ballWasSelected(sender: self)
        }
    }
    
    func getStoreItem() -> BallItem {
        let decoded  = UserDefaults.standard.object(forKey: identifier) as! Data
        let theBallItem = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! BallItem
        return theBallItem
    }
    
    func debugDrawArea(rect drawRect: CGRect) {
        let shape = SKShapeNode(rect: drawRect)
        shape.strokeColor = SKColor.red
        shape.lineWidth = 2.0
        self.addChild(shape)
    }
}




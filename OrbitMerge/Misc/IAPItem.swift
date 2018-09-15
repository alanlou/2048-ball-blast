//
//  IAPItem.swift
//  Bouncing
//
//  Created by Alan Lou on 2/13/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import SpriteKit

protocol IAPItemDelegate: NSObjectProtocol {
    func iapWasSelected(sender: IAPItem)
}

class IAPItem: SKSpriteNode {
    
    weak var IAPItemDelegate: IAPItemDelegate?
    
    var numOfBalls: Int
    
    var thisBallColor: UIColor = ColorCategory.getLineColor()
    let ballWidth: CGFloat
    let cellSize: CGSize
    
    //MARK:- Initialization
    init(color: SKColor, frameSize: CGSize, ballWidth: CGFloat, numOfBalls: Int) {
        self.ballWidth =  ballWidth
        self.numOfBalls = numOfBalls
        cellSize = frameSize
        super.init(texture: nil, color: color, size: frameSize)
        setupIAPItem(as: numOfBalls)
        self.isUserInteractionEnabled = false
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Helper Functions
    func setupIAPItem(as numOfBalls: Int) {
        self.numOfBalls = numOfBalls
        
        // get ball color
        let thisBallColor = ColorCategory.InitialBallColor
        
        // add Coin Node & label
        let extraBallNode = CoinNode(color: thisBallColor, width: ballWidth*0.9)
        extraBallNode.anchorPoint = CGPoint(x:0.0, y:0.5)
        extraBallNode.position = CGPoint(x: cellSize.width*0.15, y: cellSize.height*0.2)
        self.addChild(extraBallNode)
        
        let coinNumber = numOfBalls
        let coinNumberNode = MessageNode(message: "+\(coinNumber)")
        coinNumberNode.setFontColor(color: .white)
        let coinNumberNodeWidth = cellSize.width*0.55
        let coinNumberNodeHeight = extraBallNode.size.height+4
        let coinNumberNodeFrame = CGRect(x: -cellSize.width*0.45,
                                         y: cellSize.height*0.2-coinNumberNodeHeight/2,
                                         width: coinNumberNodeWidth,
                                         height: coinNumberNodeHeight)
        coinNumberNode.adjustLabelFontSizeToFitRect(rect: coinNumberNodeFrame)
        coinNumberNode.setHorizontalAlignment(mode: SKLabelHorizontalAlignmentMode.right)
        //debugDrawArea(rect: coinNumberNodeFrame)
        self.addChild(coinNumberNode)
        
        // add price label
        var priceNumber = 0.0
        if numOfBalls == 200 {
            priceNumber = 0.99
        } else if numOfBalls == 500 {
            priceNumber = 1.99
        } else if numOfBalls == 900 {
            priceNumber = 2.99
        }
        let priceNumberNode = MessageNode(message: "FOR $\(priceNumber)")
        priceNumberNode.setFontColor(color: .white)
        let priceNumberNodeWidth = cellSize.width*0.8
        let priceNumberNodeHeight = coinNumberNodeHeight
        let priceNumberNodeFrame = CGRect(x: -cellSize.width*0.4,
                                         y: -cellSize.height*0.2-priceNumberNodeHeight/2,
                                         width: priceNumberNodeWidth,
                                         height: priceNumberNodeHeight)
        priceNumberNode.adjustLabelFontSizeToFitRect(rect: priceNumberNodeFrame)
        priceNumberNode.setHorizontalAlignment(mode: SKLabelHorizontalAlignmentMode.center)
        //debugDrawArea(rect: priceNumberNodeFrame)
        self.addChild(priceNumberNode)
        
    }
    
    // MARK:- Helper Function
    func getInitialTouched() {
        print("getInitialTouched!")
        let fadeOut = SKAction.fadeAlpha(to: 0.7, duration: 0.2)
        self.run(fadeOut)
    }
    
    func getTouched() {
        print("getTouched!")
        if let IAPItemDelegate = IAPItemDelegate {
            IAPItemDelegate.iapWasSelected(sender: self)
        }
    }
    
    func getNumOfBalls() -> Int {
        return numOfBalls
    }
    
    func debugDrawArea(rect drawRect: CGRect) {
        let shape = SKShapeNode(rect: drawRect)
        shape.strokeColor = SKColor.red
        shape.lineWidth = 2.0
        self.addChild(shape)
    }
}




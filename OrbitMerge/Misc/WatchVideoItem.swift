//
//  WatchVideoItem.swift
//  Bouncing
//
//  Created by Alan Lou on 7/29/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import SpriteKit

protocol WatchVideoItemDelegate: NSObjectProtocol {
    func watchVideoWasSelected(sender: WatchVideoItem)
}

class WatchVideoItem: SKSpriteNode {
    
    weak var WatchVideoItemDelegate: WatchVideoItemDelegate?
    
    let cellSize: CGSize
    
    //MARK:- Initialization
    init(color: SKColor, frameSize: CGSize) {
        cellSize = frameSize
        super.init(texture: nil, color: color, size: frameSize)
        setupWatchVideoItem()
        self.isUserInteractionEnabled = false
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Helper Functions
    func setupWatchVideoItem() {
        // add video icon
        let watchVideoNode = AdsVideoNode(color: ColorCategory.getMessageFontColor(), height: cellSize.height*0.7)
        watchVideoNode.anchorPoint = CGPoint(x:1.0, y:0.5)
        watchVideoNode.position = CGPoint(x: -cellSize.width*0.3, y: 0.0)
        self.addChild(watchVideoNode)
        
        // add "Watch a Video" label
        let labelNodeUp = MessageNode(message: "WATCH")
        labelNodeUp.setFontColor(color: .white)
        let labelNodeUpWidth = cellSize.width*0.3
        let labelNodeUpHeight = cellSize.height*0.3
        let labelNodeUpFrame = CGRect(x: -cellSize.width*0.25,
                                         y: cellSize.height*0.05,
                                         width: labelNodeUpWidth,
                                         height: labelNodeUpHeight)
        labelNodeUp.adjustLabelFontSizeToFitRect(rect: labelNodeUpFrame)
        labelNodeUp.setHorizontalAlignment(mode: SKLabelHorizontalAlignmentMode.center)
        //debugDrawArea(rect: labelNodeUpFrame)
        self.addChild(labelNodeUp)
        
        let labelNodeDown = MessageNode(message: "A VIDEO")
        labelNodeDown.setFontColor(color: .white)
        let labelNodeDownFrame = CGRect(x: -cellSize.width*0.25,
                                      y: -cellSize.height*0.05-labelNodeUpHeight,
                                      width: labelNodeUpWidth,
                                      height: labelNodeUpHeight)
        labelNodeDown.adjustLabelFontSizeToFitRect(rect: labelNodeDownFrame)
        labelNodeDown.setHorizontalAlignment(mode: SKLabelHorizontalAlignmentMode.center)
        //debugDrawArea(rect: labelNodeDownFrame)
        self.addChild(labelNodeDown)
        
        // add forward arrow
        let forwardNode = ZLSpriteNode(height: cellSize.height*0.5, image: "Forward", color: SKColor.white)
        forwardNode.anchorPoint = CGPoint(x:0.0, y:0.5)
        forwardNode.position = CGPoint(x: cellSize.width*0.10, y: 0.0)
        self.addChild(forwardNode)
        
        // add Coin Node & label
        let thisBallColor = ColorCategory.InitialBallColor
        let ballWidth = cellSize.height*0.3
        let extraBallNode = CoinNode(color: thisBallColor, width: ballWidth)
        extraBallNode.anchorPoint = CGPoint(x:0.0, y:0.5)
        extraBallNode.position = CGPoint(x: cellSize.width*0.35, y: 0.0)
        self.addChild(extraBallNode)
    
        let coinNumberNode = MessageNode(message: "+15")
        coinNumberNode.setFontColor(color: .white)
        let coinNumberNodeWidth = cellSize.width*0.13
        let coinNumberNodeHeight = extraBallNode.size.height+4
        let coinNumberNodeFrame = CGRect(x: cellSize.width*0.20,
                                         y: -coinNumberNodeHeight/2,
                                         width: coinNumberNodeWidth,
                                         height: coinNumberNodeHeight)
        coinNumberNode.adjustLabelFontSizeToFitRect(rect: coinNumberNodeFrame)
        coinNumberNode.setHorizontalAlignment(mode: SKLabelHorizontalAlignmentMode.right)
        //debugDrawArea(rect: coinNumberNodeFrame)
        self.addChild(coinNumberNode)
    }
    
    // MARK:- Helper Function
    func getTouched() {
        if let WatchVideoItemDelegate = WatchVideoItemDelegate {
            WatchVideoItemDelegate.watchVideoWasSelected(sender: self)
        }
    }
    
    func debugDrawArea(rect drawRect: CGRect) {
        let shape = SKShapeNode(rect: drawRect)
        shape.strokeColor = SKColor.red
        shape.lineWidth = 2.0
        self.addChild(shape)
    }
}




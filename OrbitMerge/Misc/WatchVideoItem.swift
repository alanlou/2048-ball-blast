//
//  WatchVideoItem.swift
//  OrbitMerge
//
//  Created by Alan Lou on 7/29/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import SpriteKit

protocol WatchVideoItemDelegate: NSObjectProtocol {
    func watchVideoWasSelected(sender: WatchVideoItem)
}

class WatchVideoItem: SKSpriteNode {
    
    weak var watchVideoItemDelegate: WatchVideoItemDelegate?
    
    private var initialPosition: CGPoint
    private let frameSize: CGSize
    private let watchVideoNode: AdsVideoNode
    private let forwardNode: ZLSpriteNode
    
    //MARK:- Initialization
    init(color: SKColor, frameHeight: CGFloat) {
        
        let texture = SKTexture(imageNamed: "TopBar")
        frameSize = CGSize(width: texture.size().width*frameHeight/texture.size().height, height: frameHeight)
        self.initialPosition = CGPoint.zero
        
        watchVideoNode = AdsVideoNode(color: ColorCategory.getMenuIconColor(), height: frameHeight*0.7)
        forwardNode = ZLSpriteNode(height: frameHeight*0.5, image: "Forward", color: ColorCategory.getMenuIconColor())
        
        super.init(texture: texture, color: .clear, size: frameSize)
        self.color = ColorCategory.getBarTopColor()
        self.colorBlendFactor = 1.0
        
        setupWatchVideoItem()
        
        self.isUserInteractionEnabled = true
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Helper Functions
    func setupWatchVideoItem() {
        // add video icon
        watchVideoNode.anchorPoint = CGPoint(x:1.0, y:0.5)
        watchVideoNode.position = CGPoint(x: -frameSize.width*0.3, y: frameSize.height*0.05)
        watchVideoNode.zPosition = 1000
        self.addChild(watchVideoNode)
        
        // add "Watch a Video" label
        let labelNodeUp = MessageNode(message: "WATCH", fontName: FontNameType.Montserrat_SemiBold)
        labelNodeUp.setFontColor(color: ColorCategory.getMenuIconColor())
        let labelNodeUpWidth = frameSize.width*0.3
        let labelNodeUpHeight = frameSize.height*0.3
        let labelNodeUpFrame = CGRect(x: -frameSize.width*0.25,
                                         y: frameSize.height*0.05,
                                         width: labelNodeUpWidth,
                                         height: labelNodeUpHeight)
        labelNodeUp.adjustLabelFontSizeToFitRect(rect: labelNodeUpFrame)
        labelNodeUp.setHorizontalAlignment(mode: SKLabelHorizontalAlignmentMode.center)
        //debugDrawArea(rect: labelNodeUpFrame)
        self.addChild(labelNodeUp)
        
        let labelNodeDown = MessageNode(message: "A VIDEO", fontName: FontNameType.Montserrat_SemiBold)
        labelNodeDown.setFontColor(color: ColorCategory.getMenuIconColor())
        let labelNodeDownFrame = CGRect(x: -frameSize.width*0.25,
                                      y: -frameSize.height*0.05-labelNodeUpHeight,
                                      width: labelNodeUpWidth,
                                      height: labelNodeUpHeight)
        labelNodeDown.adjustLabelFontSizeToFitRect(rect: labelNodeDownFrame)
        labelNodeDown.setHorizontalAlignment(mode: SKLabelHorizontalAlignmentMode.center)
        //debugDrawArea(rect: labelNodeDownFrame)
        self.addChild(labelNodeDown)
        
        // add forward arrow
        forwardNode.anchorPoint = CGPoint(x:0.0, y:0.5)
        forwardNode.position = CGPoint(x: frameSize.width*0.10, y: 0.0)
        forwardNode.zPosition = 1000
        self.addChild(forwardNode)
        
        // add Coin Node & label
        let ballWidth = frameSize.height*0.31316
        let coinNode = CoinNode(width: ballWidth)
        coinNode.anchorPoint = CGPoint(x:0.0, y:0.5)
        coinNode.position = CGPoint(x: frameSize.width*0.37, y: 0.0)
        coinNode.zPosition = 1000
        self.addChild(coinNode)
    
        let coinNumberNode = MessageNode(message: "+20", fontName: FontNameType.Montserrat_SemiBold)
        coinNumberNode.setFontColor(color: ColorCategory.getMenuIconColor())
        let coinNumberNodeWidth = frameSize.width*0.13
        let coinNumberNodeHeight = coinNode.size.height+4
        let coinNumberNodeFrame = CGRect(x: frameSize.width*0.22,
                                         y: -coinNumberNodeHeight/2,
                                         width: coinNumberNodeWidth,
                                         height: coinNumberNodeHeight)
        coinNumberNode.adjustLabelFontSizeToFitRect(rect: coinNumberNodeFrame)
        coinNumberNode.setHorizontalAlignment(mode: SKLabelHorizontalAlignmentMode.right)
        //debugDrawArea(rect: coinNumberNodeFrame)
        self.addChild(coinNumberNode)
    }
    
    // MARK:- Touch Events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self.parent!)
        
        if self.contains(touchLocation) {
            let moveDown = SKAction.move(to: CGPoint(x: initialPosition.x, y:initialPosition.y-size.height*0.05), duration: 0.04)
            self.run(moveDown, withKey: "buttonMoving")
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self.parent!)
        
        if self.contains(touchLocation) {
            if let _ = self.action(forKey: "buttonMoving") {
            } else {
                let moveDown = SKAction.move(to: CGPoint(x: initialPosition.x, y:initialPosition.y-size.height*0.05), duration: 0.04)
                self.run(moveDown, withKey: "buttonMoving")
            }
        } else {
            let moveBack = SKAction.move(to: initialPosition, duration: 0.04)
            self.run(moveBack)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self.parent!)
        
        let moveBack = SKAction.move(to: initialPosition, duration: 0.04)
        self.removeAction(forKey: "buttonMoving")
        self.run(moveBack)
        
        if self.contains(touchLocation) {
            if let watchVideoItemDelegate = watchVideoItemDelegate {
                print("WATCH VIDEO CALLING HERE?")
                watchVideoItemDelegate.watchVideoWasSelected(sender: self)
            }
        }
    }
    
    // MARK:- Helper Function
    func debugDrawArea(rect drawRect: CGRect) {
        let shape = SKShapeNode(rect: drawRect)
        shape.strokeColor = SKColor.red
        shape.lineWidth = 2.0
        self.addChild(shape)
    }
    
    func updateColor() {
        self.color = ColorCategory.getBarTopColor()
        for child in self.children {
            if let msgChild = child as? MessageNode {
                msgChild.setFontColor(color: ColorCategory.getMenuIconColor())
            }
        }
        watchVideoNode.changeColor(to: ColorCategory.getMenuIconColor())
        forwardNode.changeColor(to: ColorCategory.getMenuIconColor())
        
    }
    
    func setInitialPosition(to initPos: CGPoint) {
        self.initialPosition = initPos
    }
}




//
//  StoreItem.swift
//  OrbitMerge
//
//  Created by Alan Lou on 2/13/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import SpriteKit

protocol StoreItemDelegate: NSObjectProtocol {
    func modeWasSelected(sender: StoreItem)
}

class StoreItem: SKSpriteNode {
    
    weak var storeItemDelegate: StoreItemDelegate?
    
    var identifier: String = ""
    private var isThisBought: Bool = false
    
    private let inUseNode = MessageNode(message: "IN USE", fontName: FontNameType.Montserrat_SemiBold)
    
    let cellSize: CGSize
    
    //MARK:- Initialization
    init(frameWidth: CGFloat) {
        let texture = SKTexture(imageNamed: "ModeBackground")
        cellSize = CGSize(width: frameWidth, height:texture.size().height*frameWidth/texture.size().width)
        
        super.init(texture: texture, color: .clear, size: cellSize)
        self.colorBlendFactor = 1.0
        
        self.isUserInteractionEnabled = false
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Helper Functions
    func setupStoreItem(as identifier: String) {
        
        self.identifier = identifier
        
        // clear view
        for child in self.children {
            child.removeFromParent()
        }
        
        // error case
        if  UserDefaults.standard.object(forKey: identifier) == nil {
            return
        }
        
        let decoded  = UserDefaults.standard.object(forKey: identifier) as! Data
        let theModeItem = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! ModeItem
        isThisBought = theModeItem.isBought
        
        // set up color
        self.color = ColorCategory.getBarBottomColor(mode: identifier)
        
        // add inner layer
        let innerSection = SKSpriteNode(texture: SKTexture(imageNamed: "ModeBackground"),
                                        color: ColorCategory.getBackgroundColor(mode: identifier),
                                        size: CGSize(width: cellSize.width*0.990, height:cellSize.height*0.970))
        innerSection.colorBlendFactor = 1.0
        innerSection.zPosition = 20
        innerSection.position = CGPoint.zero
        self.addChild(innerSection)
        
        // add mode title node
        let buttonWidth = self.size.width*0.27
        let xPosition = -self.size.width*0.3
        let yPosition = cellSize.height*0.25
        
        let buttonAbove = ZLSpriteNode(width: buttonWidth, image: "ModeTitle", color: ColorCategory.getBarTopColor(mode: identifier))
        buttonAbove.position = CGPoint(x: xPosition, y: yPosition)
        buttonAbove.zPosition = 22
        self.addChild(buttonAbove)
        
        let buttonBelow = ZLSpriteNode(width: buttonWidth, image: "ModeTitle", color: ColorCategory.getBarBottomColor(mode: identifier))
        buttonBelow.position = CGPoint(x: xPosition, y: yPosition-buttonAbove.size.height*0.08)
        buttonBelow.zPosition = 21
        self.addChild(buttonBelow)
        
        // add mode title text
        let modeTitleNode = MessageNode(message: "simple", fontName: FontNameType.Montserrat_SemiBold)
        modeTitleNode.setFontColor(color: ColorCategory.getMenuIconColor(mode: identifier))
        let modeTitleNodeWidth = buttonWidth*0.8
        let modeTitleNodeHeight = buttonAbove.size.height*0.50
        let modeTitleNodeFrame = CGRect(x: -modeTitleNodeWidth*0.50,
                                         y: -modeTitleNodeHeight*0.50,
                                         width: modeTitleNodeWidth,
                                         height: modeTitleNodeHeight)
        modeTitleNode.adjustLabelFontSizeToFitRect(rect: modeTitleNodeFrame)
        modeTitleNode.setHorizontalAlignment(mode: SKLabelHorizontalAlignmentMode.center)
        modeTitleNode.zPosition = 23
        modeTitleNode.setText(to: identifier)
        buttonAbove.addChild(modeTitleNode)
        
        // add color ball nodes
        let leftAndRightPadding = cellSize.width*0.5-cellSize.width*0.445
        let horizontalDistance = (self.size.width-2.0*leftAndRightPadding)/11.0
        let ballWidth = horizontalDistance*0.9
        
        for i in 1 ..< 12 {
            let colorBallNode = ZLSpriteNode(width: ballWidth, image: "CircleArea", color: ColorCategory.getBallColor(index: i, mode: identifier))
            let currXPosition = leftAndRightPadding-ballWidth*CGFloat(0.5)+horizontalDistance*CGFloat(i)-self.size.width*0.5
            let currYPosition = -ballWidth*0.7
            colorBallNode.position = CGPoint(x: currXPosition, y: currYPosition)
            colorBallNode.zPosition = CGFloat(100.0)+CGFloat(i)
            self.addChild(colorBallNode)
        }
        
        if isThisBought {
            
            return
        }
        
        // otherwise, not bought
        
        // Add Coin Node & label
        let coinNumber = 100
        let coinNumberNode = MessageNode(message: "\(coinNumber)", fontName: FontNameType.Montserrat_SemiBold)
        coinNumberNode.setFontColor(color: ColorCategory.getTextFontColor(mode: identifier))
        let coinNumberNodeWidth = cellSize.width*0.445-leftAndRightPadding
        let coinNumberNodeHeight = cellSize.height*0.11
        let coinNumberNodeFrame = CGRect(x: 0.0,
                                         y: buttonAbove.frame.midY-coinNumberNodeHeight*0.5,
                                         width: coinNumberNodeWidth,
                                         height: coinNumberNodeHeight)
        coinNumberNode.adjustLabelFontSizeToFitRect(rect: coinNumberNodeFrame)
        coinNumberNode.setHorizontalAlignment(mode: SKLabelHorizontalAlignmentMode.right)
        coinNumberNode.zPosition = 1000
        //debugDrawArea(rect: coinNumberNodeFrame)
        self.addChild(coinNumberNode)
        
        let coinNode = CoinNode(width: cellSize.height*0.13)
        coinNode.anchorPoint = CGPoint(x:1.0, y:0.5)
        coinNode.position = CGPoint(x: cellSize.width*0.5-leftAndRightPadding, y:buttonAbove.frame.midY)
        coinNode.zPosition = 1000
        self.addChild(coinNode)
        
    }
    
    func setFrameToThisItem() {
        inUseNode.setFontColor(color: ColorCategory.getBallColor(index: 2, mode: identifier))
        let inUseNodeNodeWidth = cellSize.width*0.445
        let inUseNodeNodeHeight = cellSize.height*0.10
        let inUseNodeNodeFrame = CGRect(x: 0.0,
                                         y: cellSize.height*0.25-inUseNodeNodeHeight*0.5,
                                         width: inUseNodeNodeWidth,
                                         height: inUseNodeNodeHeight)
        inUseNode.adjustLabelFontSizeToFitRect(rect: inUseNodeNodeFrame)
        inUseNode.setHorizontalAlignment(mode: SKLabelHorizontalAlignmentMode.right)
        inUseNode.zPosition = 1000
        self.addChild(inUseNode)
    }
    
    
    func removeInUseLabel() {
        inUseNode.removeFromParent()
    }
    
    // MARK:- Helper Function
    func getTouched() {
        if let storeItemDelegate = storeItemDelegate {
            storeItemDelegate.modeWasSelected(sender: self)
        }
    }
    
    func getStoreItem() -> ModeItem {
        let decoded  = UserDefaults.standard.object(forKey: identifier) as! Data
        let theModeItem = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! ModeItem
        return theModeItem
    }
    
    func debugDrawArea(rect drawRect: CGRect) {
        let shape = SKShapeNode(rect: drawRect)
        shape.strokeColor = SKColor.red
        shape.lineWidth = 2.0
        shape.zPosition = 10000
        self.addChild(shape)
    }
}




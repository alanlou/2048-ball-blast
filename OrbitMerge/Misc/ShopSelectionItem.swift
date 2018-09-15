//
//  ShopSelectionItem.swift
//  BallvsCup
//
//  Created by Alan Lou on 8/12/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import SpriteKit

protocol ShopSelectionItemDelegate: NSObjectProtocol {
    func shopSelectionWasSelected(sender: ShopSelectionItem)
}

class ShopSelectionItem: SKSpriteNode {
    
    weak var shopSelectionItemDelegate: ShopSelectionItemDelegate?
    
    let cellSize: CGSize
    let selectionIndex: Int
    
    //MARK:- Initialization
    init(color: SKColor, frameSize: CGSize, selectionIndex: Int) {
        self.cellSize = frameSize
        self.selectionIndex = selectionIndex
        
        super.init(texture: nil, color: color, size: frameSize)
        
        // add index label
        var selectionIndexText: String = ""
        switch selectionIndex {
        case 1:
            selectionIndexText = "One"
        case 2:
            selectionIndexText = "Two"
        case 3:
            selectionIndexText = "Three"
        default:
            break
        }
        
        let labelNodeUp = MessageNode(message: selectionIndexText)
        labelNodeUp.setFontColor(color: .white)
        let labelNodeUpWidth = cellSize.width*0.8
        let labelNodeUpHeight = cellSize.height*0.6
        let labelNodeUpFrame = CGRect(x: -labelNodeUpWidth*0.5,
                                      y: -labelNodeUpHeight*0.5,
                                      width: labelNodeUpWidth,
                                      height: labelNodeUpHeight)
        labelNodeUp.adjustLabelFontSizeToFitRect(rect: labelNodeUpFrame)
        labelNodeUp.setHorizontalAlignment(mode: SKLabelHorizontalAlignmentMode.center)
        //debugDrawArea(rect: labelNodeUpFrame)
        self.addChild(labelNodeUp)
        
        
        self.isUserInteractionEnabled = false
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Helper Function
    func getTouched() {
        if let shopSelectionItemDelegate = shopSelectionItemDelegate {
            shopSelectionItemDelegate.shopSelectionWasSelected(sender: self)
        }
    }
    
    func getSelectionIndex() -> Int {
        return selectionIndex
    }
    
    func debugDrawArea(rect drawRect: CGRect) {
        let shape = SKShapeNode(rect: drawRect)
        shape.strokeColor = SKColor.red
        shape.lineWidth = 2.0
        self.addChild(shape)
    }
}


//
//  MessageNode.swift
//  OrbitMerge
//
//  Created by Alan Lou on 7/15/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import SpriteKit

struct FontNameType {
    static let TruenoRg:  String = "TruenoRg"
    static let TruenoBd:  String = "TruenoBd"
    static let TruenoSBd:  String = "TruenoSBd"
    static let TruenoExBd:  String = "TruenoExBd"
    static let TruenoBlk:  String = "TruenoBlk"
    static let Montserrat_Regular:  String = "Montserrat-Regular"
    static let Montserrat_ExtraBold:  String = "Montserrat-ExtraBold"
    static let Montserrat_Black:  String = "Montserrat-Black"
    static let Montserrat_Medium:  String = "Montserrat-Medium"
    static let Montserrat_Bold:  String = "Montserrat-Bold"
    static let Montserrat_Light:  String = "Montserrat-Light"
    static let Montserrat_SemiBold:  String = "Montserrat-SemiBold"
    static let Montserrat_Thin:  String = "Montserrat-Thin"
}


class MessageNode: SKLabelNode {
    var frameRect: CGRect = CGRect()
    
    convenience init(message: String) {
        self.init(fontNamed: FontNameType.Montserrat_SemiBold) /* ChalkboardSE-Light */
        text = message
        fontName = FontNameType.Montserrat_Bold
        fontSize = 16
        fontColor = ColorCategory.getTextFontColor()
        zPosition = 2000
        horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
    }
    
    convenience init(message: String, fontName: String) {
        self.init(fontNamed: fontName) /* ChalkboardSE-Light */
        text = message
        self.fontName = fontName
        fontSize = 16
        fontColor = ColorCategory.getTextFontColor()
        zPosition = 2000
        horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
    }
    
    // helper functions
    func adjustLabelFontSizeToFitRect(rect:CGRect) {
        frameRect = rect
        // determine the font scaling factor that should let the label text fit in the given rectangle
        let scalingFactor = min(rect.width / self.frame.width, rect.height / self.frame.height)
        // change the fontSize
        self.fontSize *= scalingFactor
        // optionally move the SKLabelNode to the center of the rectangle
        self.position = CGPoint(x: rect.midX, y: rect.midY)
    }
    
    func setFont (font: String) {
        self.fontName = font
    }
    
    func setFontSize (fontSize: CGFloat) {
        self.fontSize = fontSize
    }
    
    func getFontSize() -> CGFloat{
        return self.fontSize
    }
    
    func setFontColor (color: UIColor) {
        self.fontColor = color
    }
    
    func setText(to text: String){
        self.text = text
    }
    
    func setCoinNumber(to text: String){
        // animate the update
        let duration = 0.14
        let updateText = SKAction.run() { [weak self] in
            self?.text = text
        }
        let scaleXDown = SKAction.scaleX(to: 0.8, duration: duration)
        let scaleXUp = SKAction.scaleX(to: 1.2, duration: duration)
        let scaleXBack = SKAction.scaleX(to: 1.0, duration: duration/2)
        let scaleDown = SKAction.scale(to: 0.8, duration: duration)
        let scaleBack = SKAction.scale(to: 1.0, duration: duration/2)
        self.run(SKAction.sequence([updateText,
                                    SKAction.group([scaleXDown, scaleDown]),
                                    SKAction.group([scaleBack, scaleXUp]),
                                    scaleXBack]))
    }
    
    func setScore(to text: String){
        // animate the update
        let duration = 0.14
        let updateText = SKAction.run() { [weak self] in
            self?.text = text
        }
        let scaleXDown = SKAction.scaleX(to: 0.8, duration: duration)
        let scaleXUp = SKAction.scaleX(to: 1.2, duration: duration)
        let scaleXBack = SKAction.scaleX(to: 1.0, duration: duration/2)
        let scaleDown = SKAction.scale(to: 0.8, duration: duration)
        let scaleBack = SKAction.scale(to: 1.0, duration: duration/2)
        self.run(SKAction.sequence([updateText,
                                    SKAction.group([scaleXDown, scaleDown]),
                                    SKAction.group([scaleBack, scaleXUp]),
                                    scaleXBack]))
    }
    
    func setHorizontalAlignment (mode: SKLabelHorizontalAlignmentMode) {
        horizontalAlignmentMode = mode
        if mode == SKLabelHorizontalAlignmentMode.left {
            self.position = CGPoint(x: frameRect.minX, y: frameRect.midY)
        }
        if mode == SKLabelHorizontalAlignmentMode.center {
            self.position = CGPoint(x: frameRect.midX, y: frameRect.midY)
        }
        if mode == SKLabelHorizontalAlignmentMode.right {
            self.position = CGPoint(x: frameRect.maxX, y: frameRect.midY)
        }
    }
}


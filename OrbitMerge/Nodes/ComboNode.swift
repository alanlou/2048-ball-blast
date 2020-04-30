//
//  ComboNode.swift
//  OrbitMerge
//
//  Created by Alan Lou on 9/10/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//


import SpriteKit

class ComboNode: SKLabelNode {
    private var combo: Int = 1
    private var numberDigits: Int = 1
    private var boundingRect: CGRect?
    
    override init() {
        super.init()
        text = "x\(combo)"
        fontName = FontNameType.Montserrat_SemiBold
        fontSize = 150
        fontColor = ColorCategory.getTextFontColor()
        alpha = 1.0
        zPosition = 100
        horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // helper functions
    
    func setFontColor (color: UIColor) {
        self.fontColor = color
    }
    
    func setCombo(to combo: Int){
        self.combo = combo
        if let boundingRect = boundingRect, combo.digitCount>numberDigits {
            self.adjustLabelFontSizeToFitRect(rect: boundingRect)
        }
        
        // animate the update
        let duration = 0.14
        let scaleUp = SKAction.scale(to: 1.2, duration: duration)
        let updateText = SKAction.run() { [weak self] in
            self?.text = "x\(self?.getCombo() ?? 0)"
        }
        let scaleXDown = SKAction.scaleX(to: 0.8, duration: duration)
        let scaleXUp = SKAction.scaleX(to: 1.1, duration: duration)
        let scaleXBack = SKAction.scaleX(to: 1.0, duration: duration/2)
        let scaleDown = SKAction.scale(to: 0.95, duration: duration)
        let scaleBack = SKAction.scale(to: 1.0, duration: duration/2)
        
        // reset action
        self.removeAllActions()
        self.run(SKAction.sequence([scaleUp, updateText,
                                    SKAction.group([scaleXDown, scaleDown]),
                                    SKAction.group([scaleBack, scaleXUp]),
                                    scaleXBack]))
        
        shakeNode(layer: self, duration: 0.2, magnitude: min(CGFloat(combo-1)*0.2,2.0))
    }
    
    func recallSetCombo(to combo: Int){
        self.combo = combo
        self.text = "X\(combo)"
        if let boundingRect = boundingRect, combo.digitCount>numberDigits {
            self.adjustLabelFontSizeToFitRect(rect: boundingRect)
        }
        
    }
    
    
    func adjustLabelFontSizeToFitRect(rect:CGRect) {
        if boundingRect == nil{
            boundingRect = rect
        }
        
        // determine the font scaling factor that should let the label text fit in the given rectangle
        let scalingFactor = min(rect.width / self.frame.width, rect .height / self.frame.height)
        
        // change the fontSize
        self.fontSize *= scalingFactor
        
        // optionally move the SKLabelNode to the center of the rectangle
        self.position = CGPoint(x: rect.maxX, y: rect.midY)
    }
    
    func getCombo() -> Int {
        return self.combo
    }
    
    func shakeNode(layer:SKNode, duration:Float, magnitude: CGFloat) {
        let amplitudeX:CGFloat = 10.0 * magnitude;
        let amplitudeY:CGFloat = 6.0 * magnitude;
        let numberOfShakes = duration / 0.04;
        var actionsArray:[SKAction] = [];
        for _ in 1...Int(numberOfShakes) {
            let moveX = CGFloat(arc4random_uniform(UInt32(amplitudeX))) - amplitudeX/2.0
            let moveY = CGFloat(arc4random_uniform(UInt32(amplitudeY))) - amplitudeY/2.0
            let shakeAction = SKAction.moveBy(x: CGFloat(moveX), y: CGFloat(moveY), duration: 0.02)
            shakeAction.timingMode = SKActionTimingMode.easeOut
            actionsArray.append(shakeAction)
            actionsArray.append(shakeAction.reversed())
        }
        actionsArray.append(SKAction.wait(forDuration: 1.0))
        
        let actionSeq = SKAction.sequence(actionsArray)
        layer.run(SKAction.repeatForever(actionSeq))
    }
    
}


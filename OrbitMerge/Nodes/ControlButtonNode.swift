//
//  ControlButtonNode.swift
//  BallvsCup
//
//  Created by Alan Lou on 8/8/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//


import SpriteKit

protocol ControlButtonDelegate: NSObjectProtocol {
    func controlButtonWasPressed(sender: ControlButtonNode)
}

struct ControlButtonType {
    static let PauseButton:  String = "PauseButton"
    static let SettingButton:  String = "SettingButton"
    static let BackButton:  String = "BackButton"
    static let InfoButton:  String = "Info"
}

class ControlButtonNode: SKSpriteNode {
    
    weak var buttonDelegate: ControlButtonDelegate!
    var controlButtonNode: SKSpriteNode!
    var controlButtonType: String
    
    //MARK:- Initialization
    init(color: SKColor, width: CGFloat, controlButtonType: String) {
        self.controlButtonType = controlButtonType
        
        let texture = SKTexture(imageNamed: controlButtonType)
        let textureSize = CGSize(width: width, height: width*texture.size().height/texture.size().width)
        
        // underlying larger area
        super.init(texture: nil, color: .clear, size: CGSize(width: width*2.0, height: width*2.0))
        
        self.name = "controlbutton"
        self.anchorPoint = CGPoint(x:0.0, y:0.5)
        self.isUserInteractionEnabled = true
        
        // set up Control button node
        controlButtonNode = SKSpriteNode(texture: texture, color: .clear, size: textureSize)
        controlButtonNode.colorBlendFactor = 1.0
        controlButtonNode.color = color
        controlButtonNode.anchorPoint = CGPoint(x:0.0, y:0.5)
        controlButtonNode.position = CGPoint(x:width*0.25, y:-width*0.75)
        
        // add Control button
        self.addChild(controlButtonNode)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Helper Functions
    func changeColor(to color: SKColor) {
        controlButtonNode.color = color
        controlButtonNode.colorBlendFactor = 1.0
    }
    
    func getControlButtonType() -> String {
        return self.controlButtonType
    }
    
    
    //MARK:- Touch Events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self.parent!)
        
        if self.contains(touchLocation) {
            self.buttonDelegate.controlButtonWasPressed(sender: self)
        }
    }
    
}

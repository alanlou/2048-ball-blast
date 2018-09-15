//
//  MenuButtonNode.swift
//  BreakoutDraw
//
//  Created by Alan Lou on 7/13/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//


import SpriteKit

protocol MenuButtonDelegate: NSObjectProtocol {
    func buttonWasPressed(sender: MenuButtonNode)
}

struct ButtonType {
    static let LongButton:  String = "LongButton"
    static let LongTextButton:  String = "LongTextButton"
    static let ShortButton:  String = "ShortButton"
    static let RoundButton:  String = "RoundButton"
    static let LeftButton:  String = "LeftButton"
}

struct IconType {
    static let ResumeButton:  String = "Resume"
    static let PlayButton:  String = "Resume"
    static let RestartButton:  String = "Restart"
    static let StopButton:  String = "Stop"
    static let SmallRestartButton:  String = "SmallRestart"
    static let ShareButton:  String = "Share"
    static let HomeButton:  String = "Home"
    static let SoundOnButton:  String = "Sound"
    static let SoundOffButton:  String = "SoundMute"
    static let MusicOnButton:  String = "MusicOn"
    static let MusicOffButton:  String = "MusicOff"
    static let BrightModeButton:  String = "BrightMode"
    static let DarkModeButton:  String = "DarkMode"
    static let LeaderBoardButton:  String = "Medal"
    static let StoreButton:  String = "Store"
    static let TwitterButton:  String = "Twitter"
    static let FacebookButton:  String = "Facebook"
    static let NoAdsButton:  String = "NoAds"
    static let InfoButton:  String = "Info"
    static let LikeButton:  String = "Like"
    static let MoreIconsButton:  String = "MoreIcons"
    static let RestoreIAPButton:  String = "RestoreIAP"
}

class MenuButtonNode: SKSpriteNode {
    var buttonType: String
    var iconType: String
    var iconNode: SKSpriteNode
    var textMessageNode: MessageNode?
    var gameSoundOn: Bool? {
        get {
            return UserDefaults.standard.bool(forKey: "gameSoundOn")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "gameSoundOn")
        }
    }
    var gameMusicOn: Bool? {
        get {
            return UserDefaults.standard.bool(forKey: "gameMusicOn")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "gameMusicOn")
        }
    }
    var gameModeNight: Bool? {
        get {
            return UserDefaults.standard.bool(forKey: "gameModeDark")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "gameModeDark")
        }
    }
    weak var buttonDelegate: MenuButtonDelegate!
    
    //MARK:- Initialization
    init(color: SKColor, buttonType: String, iconType: String, width: CGFloat) {
        
        self.iconNode = SKSpriteNode()
        self.buttonType = buttonType
        self.iconType = iconType
        let buttonTexture = SKTexture(imageNamed: buttonType)
        let buttonTextureSize = CGSize(width: width, height: width*buttonTexture.size().height/buttonTexture.size().width)
        super.init(texture: buttonTexture, color: .clear, size: buttonTextureSize)
        self.name = "menubutton"
        isUserInteractionEnabled = true
        
        self.color = color
        self.colorBlendFactor = 1.0
        
        // texture
        let iconTexture = SKTexture(imageNamed: iconType)
        var iconWidth = width*iconTexture.size().width/buttonTexture.size().width
        var iconHeight = width*iconTexture.size().height/buttonTexture.size().width
        if buttonType == ButtonType.LeftButton {
            iconWidth = 1.15*width*iconTexture.size().width/buttonTexture.size().height
            iconHeight = 1.15*width*iconTexture.size().height/buttonTexture.size().height
        }
        
        let iconTextureSize = CGSize(width: iconWidth, height: iconHeight)
        iconNode = SKSpriteNode(texture: iconTexture,
                                color: UIColor.white.withAlphaComponent(0.88),
                                size: iconTextureSize)
        iconNode.colorBlendFactor = 1.0
        iconNode.zPosition = 2000
        if buttonType == ButtonType.LongTextButton {
            iconNode.position = CGPoint(x:-width*0.25, y:0)
        } else {
            iconNode.position = CGPoint(x:0, y:0)
        }
        self.addChild(iconNode)
        
        if buttonType == ButtonType.RoundButton {
            self.performWobbleAction()
        }
        
        if iconType == IconType.ShareButton {
            self.performShareWobbleAction()
        }
    }
    
    convenience init(color: SKColor, buttonType: String, iconType: String, height: CGFloat) {
        
        let buttonTexture = SKTexture(imageNamed: buttonType)
        let width = height*buttonTexture.size().width/buttonTexture.size().height
        
        self.init(color: color, buttonType: buttonType, iconType: iconType, width: width)
    }
    
    convenience init(color: SKColor, buttonType: String, iconType: String, width: CGFloat, text: String) {
        self.init(color: color, buttonType: buttonType, iconType: iconType, width: width)
        
        // add text node if this is a long text button
        if buttonType == ButtonType.LongTextButton {
            
            let textNodeWidth = width*0.4
            let textNodeHeight = textNodeWidth*0.4
            let textNodeFrame = CGRect(x: -width*0.1,
                                       y: -textNodeHeight/2.0,
                                       width: textNodeWidth,
                                       height: textNodeHeight)
            
            textMessageNode = MessageNode(message: text)
            textMessageNode!.adjustLabelFontSizeToFitRect(rect: textNodeFrame)
            textMessageNode!.setHorizontalAlignment(mode: .center)
            textMessageNode!.setFontColor(color: UIColor.white.withAlphaComponent(0.88))
            //debugDrawArea(rect: textNodeFrame)
            self.addChild(textMessageNode!)
        }
    }
    
    convenience init(color: SKColor, buttonType: String, iconType: String, height: CGFloat, text: String) {
        
        let buttonTexture = SKTexture(imageNamed: buttonType)
        let width = height*buttonTexture.size().width/buttonTexture.size().height
        
        self.init(color: color, buttonType: buttonType, iconType: iconType, width: width, text: text)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Interactive Node
    func interact() {
        if iconType == IconType.SoundOnButton {
            iconType = IconType.SoundOffButton
            let texture = SKTexture(imageNamed: iconType)
            iconNode.texture = texture
            return
        }
        if iconType == IconType.SoundOffButton {
            iconType = IconType.SoundOnButton
            let texture = SKTexture(imageNamed: iconType)
            iconNode.texture = texture
            return
        }
        if iconType == IconType.MusicOnButton {
            iconType = IconType.MusicOffButton
            let texture = SKTexture(imageNamed: iconType)
            iconNode.texture = texture
            return
        }
        if iconType == IconType.MusicOffButton {
            iconType = IconType.MusicOnButton
            let texture = SKTexture(imageNamed: iconType)
            iconNode.texture = texture
            return
        }
        if iconType == IconType.DarkModeButton {
            iconType = IconType.BrightModeButton
            let texture = SKTexture(imageNamed: iconType)
            iconNode.texture = texture
            if let textMessageNode = textMessageNode{
                textMessageNode.setText(to: "Day")
            }
            // select mode
            UserDefaults.standard.set("Bright", forKey: "mode")
            return
        }
        if iconType == IconType.BrightModeButton {
            iconType = IconType.DarkModeButton
            let texture = SKTexture(imageNamed: iconType)
            iconNode.texture = texture
            if let textMessageNode = textMessageNode{
                textMessageNode.setText(to: "Night")
            }
            // select mode
            UserDefaults.standard.set("Night", forKey: "mode")
            return
        }
    }
    
    // MARK:- Touch Events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self.parent!)
        
        if self.contains(touchLocation) {
            let scaleUp = SKAction.scale(to: 1.15, duration: 0.12)
            self.run(scaleUp, withKey: "scaleup")
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self.parent!)
        
        if self.contains(touchLocation) {
            if let _ = self.action(forKey: "scaleup") {
            } else {
                let scaleUp = SKAction.scale(to: 1.15, duration: 0.12)
                self.run(scaleUp, withKey: "scaleup")
            }
        } else {
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.08)
            self.run(scaleDown)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self.parent!)
        
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.08)
        self.removeAction(forKey: "scaleup")
        self.run(scaleDown)
        
        if self.contains(touchLocation) {
            interact()
            self.buttonDelegate.buttonWasPressed(sender: self)
        }
    }
    
    //MARK:- Helper Functions
    func changeColor(to color: SKColor) {
        self.color = color
        self.colorBlendFactor = 1.0
    }
    
    func changeIconNodeColor(to color: SKColor) {
        iconNode.color = color
    }
    
    func setFontSize(to fontSize: CGFloat) {
        if let textMessageNode = textMessageNode {
            textMessageNode.setFontSize(fontSize: fontSize)
        }
    }
    
    func getFontSize() -> CGFloat {
        if let textMessageNode = textMessageNode {
            return textMessageNode.fontSize
        }
        return 0.0
    }
    
    func getIconType() -> String {
        return self.iconType
    }
    
    func performWobbleAction() {
        // perform wobble action
        let wobbleLeftSmall = SKAction.rotate(byAngle: -CGFloat.pi * 1/20, duration: 0.08)
        let wobbleRight = SKAction.rotate(byAngle: CGFloat.pi * 1/10, duration: 0.16)
        let wait = SKAction.wait(forDuration: 4.0)
        let wobbleAction = SKAction.repeatForever(SKAction.sequence([wobbleLeftSmall,wobbleRight,wobbleLeftSmall,wait]))
        self.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),wobbleAction]))
    }
    
    func performShareWobbleAction() {
        // perform wobble action
        let wobbleLeftSmall1 = SKAction.rotate(byAngle: -CGFloat.pi * 1/7, duration: 0.22)
        let wobbleRight = SKAction.rotate(byAngle: CGFloat.pi * 1/3.5, duration: 0.44)
        let wobbleLeftSmall2 = SKAction.rotate(byAngle: -CGFloat.pi * 1/7, duration: 0.22)
        wobbleLeftSmall1.timingMode = .easeOut
        wobbleRight.timingMode = .easeInEaseOut
        wobbleLeftSmall2.timingMode = .easeIn
        let wobbleAction = SKAction.repeatForever(SKAction.sequence([wobbleLeftSmall1,wobbleRight,wobbleLeftSmall2]))
        iconNode.run(wobbleAction)
    }
    
    func debugDrawArea(rect drawRect: CGRect) {
        let shape = SKShapeNode(rect: drawRect)
        shape.strokeColor = SKColor.red
        shape.lineWidth = 2.0
        self.addChild(shape)
    }
    
}

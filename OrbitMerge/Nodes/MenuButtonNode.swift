//
//  MenuButtonNode.swift
//  OrbitMerge
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
    static let MenuButton:  String = "MenuButton"
    static let StartButton:  String = "CircleArea"
}

struct IconType {
    static let ResumeButton:  String = "Resume"
    static let PlayButton:  String = "Resume"
    static let RestartButton:  String = "Restart"
    static let BackButton:  String = "BackButton"
    static let StopButton:  String = "Stop"
    static let SmallRestartButton:  String = "Restart"
    static let ShareButton:  String = "Share"
    static let HomeButton:  String = "Home"
    static let SoundOnButton:  String = "Sound"
    static let SoundOffButton:  String = "SoundMute"
    static let MusicOnButton:  String = "MusicOn"
    static let MusicOffButton:  String = "MusicOff"
    static let VibrateButton:  String = "Vibrate"
    static let VibrateMuteButton:  String = "VibrateMute"
    static let ModeButton:  String = "Mode"
    static let LeaderBoardButton:  String = "Medal"
    static let StoreButton:  String = "Store"
    static let TwitterButton:  String = "Twitter"
    static let FacebookButton:  String = "Facebook"
    static let NoAdsButton:  String = "NoAds"
    static let InfoButton:  String = "Info"
    static let LikeButton:  String = "Like"
    static let MoreIconsButton:  String = "MoreIcons"
    static let RestoreIAPButton:  String = "RestoreIAP"
    static let SettingButton:  String = "Setting"
    static let NoButton:  String = "None"
}

class MenuButtonNode: SKSpriteNode {
    var buttonType: String
    var iconType: String
    var iconNode: SKSpriteNode
    var initialPosition: CGPoint
    var isPushDown: Bool
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
        self.initialPosition = CGPoint.zero
        let buttonTexture = SKTexture(imageNamed: buttonType)
        let buttonHeight = width*buttonTexture.size().height/buttonTexture.size().width
        let buttonTextureSize = CGSize(width: width, height: buttonHeight)
        if buttonType == ButtonType.MenuButton ||
            (iconType == IconType.SmallRestartButton && buttonType == ButtonType.LongTextButton) {
            isPushDown = true
        } else {
            isPushDown = false
        }
        super.init(texture: buttonTexture, color: .clear, size: buttonTextureSize)
        self.name = "menubutton"
        isUserInteractionEnabled = true
        
        self.color = color
        self.colorBlendFactor = 1.0
        
        if iconType == IconType.NoButton {
            return
        }
        
        // icon texture
        let iconTexture = SKTexture(imageNamed: iconType)
        var iconHeight = buttonHeight*(1.7/3.0)
        var iconWidth = iconTexture.size().width*iconHeight/iconTexture.size().height
        if buttonType == ButtonType.LeftButton {
            iconWidth = 1.15*iconWidth
            iconHeight = 1.15*iconHeight
        } else if buttonType == ButtonType.ShortButton {
            iconWidth = 1.20*iconWidth
            iconHeight = 1.20*iconHeight
        } else if buttonType == ButtonType.MenuButton {
            iconWidth = buttonHeight*0.618
            iconHeight = buttonHeight*0.618
            if iconType == IconType.BackButton {
                iconWidth = buttonHeight*0.56
                iconHeight = buttonHeight*0.56
            }
        } else if buttonType == ButtonType.StartButton {
            iconHeight = buttonHeight*(0.38)
            iconWidth = iconTexture.size().width*iconHeight/iconTexture.size().height
        }
        
        let iconTextureSize = CGSize(width: iconWidth, height: iconHeight)
        iconNode = SKSpriteNode(texture: iconTexture,
                                color: .clear,
                                size: iconTextureSize)
        iconNode.color = ColorCategory.getMenuIconColor()
        iconNode.colorBlendFactor = 1.0
        iconNode.zPosition = 2000
        if buttonType == ButtonType.LongTextButton {
            iconNode.position = CGPoint(x:-width*0.25, y:0)
        } else if buttonType == ButtonType.MenuButton {
            iconNode.position = CGPoint(x:0.0, y:buttonHeight*0.04)
        } else if buttonType == ButtonType.StartButton {
            iconNode.position = CGPoint(x:width*0.035, y:0.0)
        } else {
            iconNode.position = CGPoint(x:0.0, y:0.0)
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
            textMessageNode!.setFontColor(color: .white)
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
        if iconType == IconType.VibrateButton {
            iconType = IconType.VibrateMuteButton
            let texture = SKTexture(imageNamed: iconType)
            iconNode.texture = texture
            return
        }
        if iconType == IconType.VibrateMuteButton {
            iconType = IconType.VibrateButton
            let texture = SKTexture(imageNamed: iconType)
            iconNode.texture = texture
            return
        }
    }
    
    // MARK:- Touch Events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self.parent!)
        print(buttonType)
        if self.contains(touchLocation) {
            if isPushDown {
                let moveDown = SKAction.move(to: CGPoint(x: initialPosition.x, y:initialPosition.y-size.height*0.05), duration: 0.04)
                self.run(moveDown, withKey: "buttonMoving")
            } else {
                let scaleUp = SKAction.scale(to: 1.15, duration: 0.12)
                self.run(scaleUp, withKey: "buttonMoving")
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self.parent!)
        
        if self.contains(touchLocation) {
            if let _ = self.action(forKey: "buttonMoving") {
            } else {
                if isPushDown {
                    let moveDown = SKAction.move(to: CGPoint(x: initialPosition.x, y:initialPosition.y-size.height*0.05), duration: 0.04)
                    self.run(moveDown, withKey: "buttonMoving")
                } else {
                    let scaleUp = SKAction.scale(to: 1.15, duration: 0.12)
                    self.run(scaleUp, withKey: "buttonMoving")
                }
            }
        } else {
            if isPushDown {
                let moveBack = SKAction.move(to: initialPosition, duration: 0.04)
                self.run(moveBack)
            } else {
                let scaleDown = SKAction.scale(to: 1.0, duration: 0.08)
                self.run(scaleDown)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self.parent!)
        
        if isPushDown {
            let moveBack = SKAction.move(to: initialPosition, duration: 0.04)
            self.removeAction(forKey: "buttonMoving")
            self.run(moveBack)
        } else {
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.08)
            self.removeAction(forKey: "buttonMoving")
            self.run(scaleDown)
        }
        
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
    
    func setInitialPosition(to initPos: CGPoint) {
        self.initialPosition = initPos
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

//
//  MenuScene.swift
//  OrbitMerge
//
//  Created by Alan Lou on 9/15/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import SpriteKit
import Firebase
import GameKit

class MenuScene: SKScene, MenuButtonDelegate {
    
    // super node containing the gamelayer and settinglayer
    private let nodeLayer = SKNode()
    private let startLayer = SKNode()
    private let settingLayer = SKNode()

    // nodes
    private var topBarNode: TopBarNode
    private var backButtonNode: MenuButtonNode?
    private var settingButton: MenuButtonNode!
    private var titleNode: ZLSpriteNode?
    private var circleAreaNode: ZLSpriteNode
    
    // variables
    private var safeAreaRect: CGRect!
    private var bottomSafeSets: CGFloat!
    
    // numbers
    private let universalWidth: CGFloat
    private let circleRadius: CGFloat
    private let ballWidth: CGFloat
    
    // booleans
    var isAdReady: Bool = false
    var isFirstTimeOpening: Bool = false
    
    // IAP Product
    private var products = [SKProduct]()

    // pre-load sound
    private let buttonPressedSound: SKAction = SKAction.playSoundFileNamed("buttonPressed.wav", waitForCompletion: false)
    
    // stored values
    private var gameSoundOn: Bool {
        get {
            if  UserDefaults.standard.object(forKey: "gameSoundOn") == nil {
                UserDefaults.standard.set(true, forKey: "gameSoundOn")
            }
            return UserDefaults.standard.bool(forKey: "gameSoundOn")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "gameSoundOn")
        }
    }
    private var bestScore: Int {
        get {
            return UserDefaults.standard.integer(forKey: "highScore")
        }
    }
    private var highCombo: Int {
        get {
            return UserDefaults.standard.integer(forKey: "highCombo")
        }
    }
    private var highBallNum: Int {
        get {
            return UserDefaults.standard.integer(forKey: "highBallNum")
        }
    }
    private var adsHeight: CGFloat {
        get {
            return CGFloat(UserDefaults.standard.float(forKey: "AdsHeight"))
        }
    }
    
    
    //MARK:- Initialization
    override init(size: CGSize) {
        // define numbers
        universalWidth = min(size.width, size.height*9.0/16.0)
        circleRadius =  universalWidth*0.425
        ballWidth = circleRadius * 0.190
        
        // define nodes
        topBarNode = TopBarNode(width: universalWidth*0.8)
        circleAreaNode = ZLSpriteNode(width: circleRadius*2.5, image: "CircleArea", color: ColorCategory.getStartButtonColor().withAlphaComponent(0.5))
        
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didMove(to view: SKView) {
        
        /*** set up background ***/
        self.backgroundColor = ColorCategory.getBackgroundColor()
        self.view?.isMultipleTouchEnabled = false
        
        var safeSets:UIEdgeInsets
        if #available(iOS 11.0, *) {
            safeSets = view.safeAreaInsets
        } else {
            safeSets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        }
        
        /*** define variables ***/
        safeAreaRect = CGRect(x: safeSets.left,
                              y: safeSets.bottom,
                              width: size.width-safeSets.right-safeSets.left,
                              height: size.height-safeSets.top-safeSets.bottom)
        bottomSafeSets = safeSets.bottom
        
        /*** set up layers ***/
        nodeLayer.position = CGPoint(x: 0.0, y: bottomSafeSets)
        self.addChild(nodeLayer)
        nodeLayer.name = "nodelayer"
        
        startLayer.position = CGPoint(x: 0.0, y: bottomSafeSets)
        self.addChild(startLayer)
        startLayer.name = "startlayer"
        
        /*** set up setting layer ***/
        setUpSettingLayer()
        
        /*** set up top bar node ***/
        topBarNode.anchorPoint = CGPoint(x:0.5, y:1.0)
        topBarNode.position = CGPoint(x:safeAreaRect.width*0.5, y: safeAreaRect.height*0.9+topBarNode.size.height*0.5)
        nodeLayer.addChild(topBarNode)
        setUpTopBarNode()
        
        /*** set up title ***/
        titleNode = ZLSpriteNode(width:universalWidth*0.7, image: "pic_title_day")
        titleNode!.position = CGPoint(x:size.width*0.5, y: safeAreaRect.height*0.7)
        startLayer.addChild(titleNode!)
        
        /*** set up start button ***/
        let startButtonWidth = universalWidth*0.35
        let startButton = MenuButtonNode(color: ColorCategory.getStartButtonColor(),
                                         buttonType: ButtonType.StartButton,
                                         iconType: IconType.ResumeButton,
                                         height: startButtonWidth)
        startButton.changeIconNodeColor(to: .white)
        startButton.zPosition = 100
        startButton.position = CGPoint(x: safeAreaRect.width/2,
                                       y: (titleNode!.frame.minY+(safeAreaRect.height*CGFloat(0.20)+universalWidth*CGFloat(0.10)))*CGFloat(0.5))
        startButton.name = "restartButton"
        startButton.buttonDelegate = self
        startLayer.addChild(startButton)
        
        /*** set up circle area node ***/
        circleAreaNode.position = startButton.position
        circleAreaNode.zPosition = 0
        circleAreaNode.alpha = 0.0
        circleAreaNode.setScale(0.0)
        startLayer.addChild(circleAreaNode)
        expandCircleArea(color: ColorCategory.getStartButtonColor())
        
        /*** set up bottom section ***/
        setUpBottomSection()
    }
    
    func setUpBottomSection() {
        
        let buttonWidth = universalWidth*0.15
        
        // add leaderboard button
        let leaderboardButton = MenuButtonNode(color: ColorCategory.getBarTopColor(),
                                               buttonType: ButtonType.MenuButton,
                                               iconType: IconType.LeaderBoardButton,
                                               width: buttonWidth)
        leaderboardButton.zPosition = 100
        leaderboardButton.position = CGPoint(x: safeAreaRect.width*0.5-universalWidth*0.30,
                                             y: safeAreaRect.height*0.20-buttonWidth*0.5)
        leaderboardButton.name = "leaderboardbutton"
        leaderboardButton.buttonDelegate = self
        nodeLayer.addChild(leaderboardButton)
        
        // add sound button
        let iconTypeHere = gameSoundOn ? IconType.SoundOnButton : IconType.SoundOffButton
        let soundButton = MenuButtonNode(color: ColorCategory.getBarTopColor(),
                                         buttonType: ButtonType.MenuButton,
                                         iconType: iconTypeHere,
                                         width: buttonWidth)
        soundButton.zPosition = 100
        soundButton.position = CGPoint(x: safeAreaRect.width*0.5-universalWidth*0.10,
                                       y: safeAreaRect.height*0.20-buttonWidth*0.5)
        soundButton.name = "soundbutton"
        soundButton.buttonDelegate = self
        nodeLayer.addChild(soundButton)
        
        // add mode button
        let modeButton = MenuButtonNode(color: ColorCategory.getBarTopColor(),
                                         buttonType: ButtonType.MenuButton,
                                         iconType: IconType.ModeButton,
                                         width: buttonWidth)
        modeButton.zPosition = 100
        modeButton.position = CGPoint(x: safeAreaRect.width*0.5+universalWidth*0.10,
                                       y: safeAreaRect.height*0.20-buttonWidth*0.5)
        modeButton.name = "modebutton"
        modeButton.buttonDelegate = self
        nodeLayer.addChild(modeButton)
        
        // add setting button
        settingButton = MenuButtonNode(color: ColorCategory.getBarTopColor(),
                                               buttonType: ButtonType.MenuButton,
                                               iconType: IconType.SettingButton,
                                               width: buttonWidth)
        settingButton.zPosition = 100
        settingButton.position = CGPoint(x: safeAreaRect.width*0.5+universalWidth*0.30,
                                             y: safeAreaRect.height*0.20-buttonWidth*0.5)
        settingButton.name = "settingbutton"
        settingButton.buttonDelegate = self
        nodeLayer.addChild(settingButton)
        
        // add menu button shadow
        let buttonBelow1 = ZLSpriteNode(width: buttonWidth, image: "MenuButton", color: ColorCategory.getBarBottomColor())
        leaderboardButton.setInitialPosition(to: leaderboardButton.position)
        buttonBelow1.position = CGPoint(x: leaderboardButton.position.x, y: leaderboardButton.position.y-buttonWidth*0.08)
        buttonBelow1.zPosition = 50
        nodeLayer.addChild(buttonBelow1)
        
        let buttonBelow2 = ZLSpriteNode(width: buttonWidth, image: "MenuButton", color: ColorCategory.getBarBottomColor())
        soundButton.setInitialPosition(to: soundButton.position)
        buttonBelow2.position = CGPoint(x: soundButton.position.x, y: soundButton.position.y-buttonWidth*0.08)
        buttonBelow2.zPosition = 50
        nodeLayer.addChild(buttonBelow2)
        
        let buttonBelow3 = ZLSpriteNode(width: buttonWidth, image: "MenuButton", color: ColorCategory.getBarBottomColor())
        modeButton.setInitialPosition(to: modeButton.position)
        buttonBelow3.position = CGPoint(x: modeButton.position.x, y: modeButton.position.y-buttonWidth*0.08)
        buttonBelow3.zPosition = 50
        nodeLayer.addChild(buttonBelow3)
        
        let buttonBelow4 = ZLSpriteNode(width: buttonWidth, image: "MenuButton", color: ColorCategory.getBarBottomColor())
        settingButton.setInitialPosition(to: settingButton.position)
        buttonBelow4.position = CGPoint(x: settingButton.position.x, y: settingButton.position.y-buttonWidth*0.08)
        buttonBelow4.zPosition = 50
        nodeLayer.addChild(buttonBelow4)
        
    }
    
    //MARK:- Top Bar Handling
    func setUpTopBarNode() {
        // set up top score message node
        let scoreTopMessageNodeWidth = universalWidth*0.2
        let scoreTopMessageNodeHeight = topBarNode.size.height*0.15
        let scoreTopMessageNodeFrame = CGRect(x: -scoreTopMessageNodeWidth*0.5,
                                              y: -scoreTopMessageNodeHeight-5,
                                              width: scoreTopMessageNodeWidth,
                                              height: scoreTopMessageNodeHeight)
        let scoreTopMessage = MessageNode(message: "HIGH SCORE", fontName: FontNameType.Montserrat_SemiBold)
        scoreTopMessage.zPosition = 100
        scoreTopMessage.setFontColor(color: ColorCategory.getMenuIconColor())
        scoreTopMessage.adjustLabelFontSizeToFitRect(rect: scoreTopMessageNodeFrame)
        topBarNode.addChild(scoreTopMessage)
        //debugDrawTopBarArea(rect: scoreTopMessageNodeFrame)
        
        // set up score message node
        let scoreMessageNodeWidth = universalWidth*0.3
        let scoreMessageNodeHeight = topBarNode.size.height*0.65
        let scoreMessageNodeFrame = CGRect(x: -scoreMessageNodeWidth*0.5,
                                           y: -topBarNode.size.height+topBarNode.size.height*0.08,
                                           width: scoreMessageNodeWidth,
                                           height: scoreMessageNodeHeight)
        let scoreNode: MessageNode = MessageNode(message: "\(bestScore)", fontName: FontNameType.Montserrat_SemiBold)
        scoreNode.zPosition = 100
        scoreNode.setFontColor(color: ColorCategory.getMenuIconColor())
        scoreNode.adjustLabelFontSizeToFitRect(rect: scoreMessageNodeFrame)
        topBarNode.addChild(scoreNode)
        //debugDrawTopBarArea(rect: scoreMessageNodeFrame)
        
        // set up top high score message node
        let comboTopMessageNodeWidth = universalWidth*0.2
        let comboTopMessageNodeHeight = topBarNode.size.height*0.15
        let comboTopMessageNodeFrame = CGRect(x: universalWidth*0.365-5-comboTopMessageNodeWidth,
                                                  y: -comboTopMessageNodeHeight-5,
                                                  width: comboTopMessageNodeWidth,
                                                  height: comboTopMessageNodeHeight)
        let comboTopMessage = MessageNode(message: "MAX COMBO", fontName: FontNameType.Montserrat_SemiBold)
        comboTopMessage.zPosition = 100
        comboTopMessage.setFontColor(color: ColorCategory.getMenuIconColor())
        comboTopMessage.adjustLabelFontSizeToFitRect(rect: comboTopMessageNodeFrame)
        comboTopMessage.setHorizontalAlignment(mode: .right)
        topBarNode.addChild(comboTopMessage)
        //debugDrawTopBarArea(rect: comboTopMessageNodeFrame)
        
        // set up best score message node
        let comboMessageNodeWidth = universalWidth*0.20
        let comboMessageNodeHeight = topBarNode.size.height*0.35
        let comboMessageNodeFrame = CGRect(x: universalWidth*0.365-5-comboMessageNodeWidth,
                                               y: -topBarNode.size.height+topBarNode.size.height*0.24+ballWidth*CGFloat(0.05),
                                               width: comboMessageNodeWidth,
                                               height: comboMessageNodeHeight)
        let comboNode: MessageNode = MessageNode(message: "x\(highCombo)", fontName: FontNameType.Montserrat_SemiBold)
        comboNode.zPosition = 100
        comboNode.setFontColor(color: ColorCategory.getMenuIconColor())
        comboNode.adjustLabelFontSizeToFitRect(rect: comboMessageNodeFrame)
        comboNode.setHorizontalAlignment(mode: .right)
        topBarNode.addChild(comboNode)
        //debugDrawTopBarArea(rect: comboMessageNodeFrame)
        
        // set up top high score message node
        let highIndexTopMessageNodeWidth = universalWidth*0.3
        let highIndexTopMessageNodeHeight = topBarNode.size.height*0.15
        let highIndexTopMessageNodeFrame = CGRect(x: -universalWidth*0.365+5,
                                                  y: -highIndexTopMessageNodeHeight-5,
                                                  width: highIndexTopMessageNodeWidth,
                                                  height: highIndexTopMessageNodeHeight)
        let highIndexTopMessage = MessageNode(message: "MAX BALL", fontName: FontNameType.Montserrat_SemiBold)
        highIndexTopMessage.zPosition = 100
        highIndexTopMessage.setFontColor(color: ColorCategory.getMenuIconColor())
        highIndexTopMessage.adjustLabelFontSizeToFitRect(rect: highIndexTopMessageNodeFrame)
        highIndexTopMessage.setHorizontalAlignment(mode: .left)
        topBarNode.addChild(highIndexTopMessage)
        
        // set up ball node
        let upperLeftBallNode = BallNode(width: ballWidth*0.7, index: highBallNum)
        upperLeftBallNode.zPosition = 10
        upperLeftBallNode.position = CGPoint(x: -universalWidth*CGFloat(0.365)+CGFloat(5.0)+ballWidth*CGFloat(0.35),
                                             y: -topBarNode.size.height+topBarNode.size.height*0.24+ballWidth*CGFloat(0.35))
        topBarNode.addChild(upperLeftBallNode)
        
    }
    
    
    //MARK:- Setting Menu Handling
    func setUpSettingLayer() {
        
        /*** set up pause layer ***/
        
        // calculate button numbers
        let verticleDistance = min(safeAreaRect.size.width*0.1818,safeAreaRect.size.height*0.1023)
        let buttonWidth = min(safeAreaRect.size.width*0.5,safeAreaRect.size.height*0.281)
        let yLevel = safeAreaRect.height*0.55
        
        // add facebook button
        let facebookButton = MenuButtonNode(color: ColorCategory.BallColor1_Simple,
                                            buttonType: ButtonType.LongTextButton,
                                            iconType: IconType.FacebookButton,
                                            width: buttonWidth,
                                            text: "Facebook")
        facebookButton.zPosition = 10000
        facebookButton.position = CGPoint(x: safeAreaRect.width/2,
                                          y: yLevel + verticleDistance*1.5)
        facebookButton.name = "facebookButton"
        facebookButton.changeIconNodeColor(to: .white)
        facebookButton.buttonDelegate = self
        settingLayer.addChild(facebookButton)
        
        // add twitter button
        let twitterButton = MenuButtonNode(color: ColorCategory.BallColor2_Simple,
                                           buttonType: ButtonType.LongTextButton,
                                           iconType: IconType.TwitterButton,
                                           width: buttonWidth,
                                           text: "Twitter")
        twitterButton.zPosition = 10000
        twitterButton.position = CGPoint(x: safeAreaRect.width/2,
                                         y: yLevel + verticleDistance*0.5)
        twitterButton.name = "twitterButton"
        twitterButton.changeIconNodeColor(to: .white)
        twitterButton.buttonDelegate = self
        twitterButton.setFontSize(to: facebookButton.getFontSize())
        settingLayer.addChild(twitterButton)
        
        // add like button
        let likeButton = MenuButtonNode(color: ColorCategory.BallColor3_Simple,
                                        buttonType: ButtonType.LongTextButton,
                                        iconType: IconType.LikeButton,
                                        width: buttonWidth,
                                        text: "Like")
        likeButton.zPosition = 10000
        likeButton.position = CGPoint(x: safeAreaRect.width/2,
                                      y: yLevel - verticleDistance*0.5)
        likeButton.name = "likebutton"
        likeButton.changeIconNodeColor(to: .white)
        likeButton.buttonDelegate = self
        likeButton.setFontSize(to: facebookButton.getFontSize())
        settingLayer.addChild(likeButton)
        
        // add no ads button
        let noAdsButton = MenuButtonNode(color: ColorCategory.BallColor6_Simple,
                                         buttonType: ButtonType.ShortButton,
                                         iconType: IconType.NoAdsButton,
                                         width: buttonWidth*0.4545)
        noAdsButton.zPosition = 10000
        noAdsButton.position = CGPoint(x: safeAreaRect.width/2-facebookButton.size.width/2+noAdsButton.size.width/2,
                                       y: yLevel - verticleDistance*1.5)
        noAdsButton.name = "noadsbutton"
        noAdsButton.changeIconNodeColor(to: .white)
        noAdsButton.buttonDelegate = self
        settingLayer.addChild(noAdsButton)
        
        // add restore iap button
        let restoreIAPButton = MenuButtonNode(color: ColorCategory.BallColor7_Simple,
                                              buttonType: ButtonType.ShortButton,
                                              iconType: IconType.RestoreIAPButton,
                                              width: buttonWidth*0.4545)
        restoreIAPButton.zPosition = 10000
        restoreIAPButton.position = CGPoint(x: safeAreaRect.width/2+facebookButton.size.width/2-noAdsButton.size.width/2,
                                            y: yLevel - verticleDistance*1.5)
        restoreIAPButton.name = "restoreiapbutton"
        restoreIAPButton.changeIconNodeColor(to: .white)
        restoreIAPButton.buttonDelegate = self
        settingLayer.addChild(restoreIAPButton)
        
    }
    
    // MARK:- Button Pressed
    func buttonWasPressed(sender: MenuButtonNode) {
        let iconType = sender.getIconType()
        
        // play sound
        if gameSoundOn,
            iconType != IconType.SoundOffButton {
            self.run(buttonPressedSound)
        }
        if !gameSoundOn,
            iconType == IconType.SoundOnButton {
            self.run(buttonPressedSound)
        }
        
        /* go through each possible button type */
        if iconType == IconType.SoundOnButton  {
            gameSoundOn = true
            return
        }
        if iconType == IconType.SoundOffButton  {
            gameSoundOn = false
            return
        }
        if iconType == IconType.ResumeButton  {
            if view != nil {
                let scene = GameScene(size: size)
                scene.isAdReady = self.isAdReady
                scene.isFirstTimeOpening = self.isFirstTimeOpening
                let transition:SKTransition = SKTransition.fade(withDuration: 0.5)
                self.view?.presentScene(scene, transition: transition)
            }
            return
        }
        if iconType == IconType.FacebookButton  {
            let fbInstalled = schemeAvailable("fb://")
            
            if fbInstalled {
                // If user twitter installed
                guard let url = URL(string: "fb://profile/349909612079389") else {
                    return
                }
                
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            } else {
                // If user does not have twitter installed
                guard let url = URL(string: "https://www.facebook.com/RawwrStudios") else {
                    return
                }
                
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
            
            return
        }
        if iconType == IconType.TwitterButton  {
            let twInstalled = schemeAvailable("twitter://")
            
            if twInstalled {
                // If user twitter installed
                guard let url = URL(string: "twitter://user?screen_name=rawwrstudios") else {
                    return
                }
                
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            } else {
                // If user does not have twitter installed
                guard let url = URL(string: "https://mobile.twitter.com/rawwrstudios") else {
                    return
                }
                
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
            
            return
        }
        if iconType == IconType.LikeButton {
            let userInfoDict:[String: String] = ["forButton": "like"]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "displayAlertMessage"), object: nil, userInfo: userInfoDict)
            return
        }
        if iconType == IconType.LeaderBoardButton {
            let userInfoDict:[String: String] = ["forButton": "leaderboard"]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "displayAlertMessage"), object: nil, userInfo: userInfoDict)
            return
        }
        if iconType == IconType.NoAdsButton {
            if !IAPHelper.canMakePayments() {
                let userInfoDict:[String: String] = ["forButton": "iapfail"]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "displayAlertMessage"), object: nil, userInfo: userInfoDict)
            }
            
            products = []
            IAPProducts.store.requestProducts{success, products in
                if success {
                    // no enough iap
                    if products == nil || products?.count != 1 {
                        let userInfoDict:[String: String] = ["forButton": "iapfail"]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "displayAlertMessage"), object: nil, userInfo: userInfoDict)
                        return
                    }
                    self.products = products!
                    
                    // buy selected product
                    let thisProduct = self.products[0] as SKProduct
                    if thisProduct.productIdentifier == IAPProducts.NoAds {
                        IAPProducts.store.buyProduct(thisProduct)
                        return
                    }
                    
                }
            }
            return
        }
        if iconType == IconType.RestoreIAPButton  {
            IAPProducts.store.restorePurchases()
            return
        }
        if iconType == IconType.ModeButton {
            //print("GO TO STORE!")
            if view != nil {
                let transition:SKTransition = SKTransition.fade(withDuration: 0.5)
                let storeScene = StoreScene(size: self.size)
                storeScene.isAdReady = self.isAdReady
                self.view?.presentScene(storeScene, transition: transition)
            }
            return
        }
        if iconType == IconType.SettingButton {
            
            // set up back button node
            let buttonWidth = settingButton.size.width
            backButtonNode = MenuButtonNode(color: ColorCategory.getBarTopColor(),
                                            buttonType: ButtonType.MenuButton,
                                            iconType: IconType.BackButton,
                                            width: buttonWidth)
            backButtonNode!.zPosition = 500
            backButtonNode!.position = settingButton.initialPosition
            backButtonNode!.setInitialPosition(to: settingButton.initialPosition)
            backButtonNode!.isUserInteractionEnabled = false
            backButtonNode!.name = "backbutton"
            backButtonNode!.buttonDelegate = self
            nodeLayer.addChild(backButtonNode!)
            
            // define actions
            let moveRight = SKAction.move(by: CGVector(dx: ballWidth*3.0*0.15, dy: 0), duration: 0.03)
            let moveLeft = SKAction.move(by: CGVector(dx: -ballWidth*3.0*1.55, dy: 0), duration: 0.2)
            moveLeft.timingMode = .easeIn
            //let wait1 = SKAction.wait(forDuration: 0.07)
            let wait2 = SKAction.wait(forDuration: 0.14)
            
            // slide left start layer
            let moveDuration = 0.18*safeAreaRect.width*0.885/(ballWidth*3.0*1.55) // 0.885 = 0.77*0.5+0.5
            let moveLayerLeft = SKAction.move(by: CGVector(dx: -safeAreaRect.width*CGFloat(0.885+0.05)-CGFloat(ballWidth*3.0*0.15), dy: 0), duration: TimeInterval(moveDuration))
            let moveLayerRight = SKAction.move(by: CGVector(dx: safeAreaRect.width*0.05, dy: 0), duration: 0.08)
            moveLayerLeft.timingMode = .easeIn
            startLayer.run(SKAction.sequence([wait2,moveRight,moveLayerLeft]))
            
            // get in setting layer
            settingLayer.position = CGPoint(x:safeAreaRect.width*(0.885), y:bottomSafeSets)
            self.addChild(settingLayer)
            settingLayer.name = "settinglayer"
            
            settingLayer.run(SKAction.sequence([wait2,moveRight,moveLayerLeft,moveLayerRight]), completion:{ [weak self] in
                self?.backButtonNode!.isUserInteractionEnabled = true
            })
            
            
            // animate back button
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            fadeOut.timingMode = .easeOut
            settingButton.run(fadeOut)
            settingButton.isUserInteractionEnabled = false
            
            let fadeIn = SKAction.fadeIn(withDuration: 0.3)
            fadeIn.timingMode = .easeIn
            backButtonNode!.run(fadeIn)
            
            return
        }
        if iconType == IconType.BackButton  {
            // slide in start layer
            //startLayer.isUserInteractionEnabled = true
            let moveDuration = 0.18*safeAreaRect.width*0.885/(ballWidth*3.0*1.55) // 0.885 = 0.77*0.5+0.5
            let moveLayerLeft = SKAction.move(by: CGVector(dx: -safeAreaRect.width*0.05, dy: 0.0), duration: 0.08)
            let moveLayerRight = SKAction.move(by: CGVector(dx: safeAreaRect.width*0.05-startLayer.position.x, dy: 0.0), duration: TimeInterval(moveDuration))
            moveLayerRight.timingMode = .easeOut
            startLayer.run(SKAction.sequence([moveLayerRight,moveLayerLeft]))
            
            // slide out setting layer
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            if let backButtonNode = backButtonNode {
                backButtonNode.isUserInteractionEnabled = false
                backButtonNode.run(fadeOut, completion:{
                    backButtonNode.removeFromParent()
                })
            }
            let fadeIn = SKAction.fadeIn(withDuration: 0.3)
            fadeIn.timingMode = .easeIn
            settingButton.run(fadeIn)
            
            settingLayer.run(moveLayerRight, completion: {[weak self] in
                self?.settingLayer.removeFromParent()
                self?.settingButton.isUserInteractionEnabled = true
            })
            
            return
        }
        
    }
    
    
    //MARK:- Helper Functions
    func expandCircleArea(color: SKColor) {
        let circleOutDuration: TimeInterval = 4.0
        let circleAreaFadeAndExpand = SKAction.group([SKAction.fadeOut(withDuration: circleOutDuration),
                                                      SKAction.scale(to: 0.5, duration: circleOutDuration)])
        let circleAreaScaleBack = SKAction.scale(to: 0.0, duration: 0.5)
        let circleAreaFadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        let circleSequenceAction = SKAction.sequence([circleAreaFadeAndExpand,circleAreaScaleBack,circleAreaFadeIn])
        circleAreaFadeIn.timingMode = .easeOut
        circleAreaNode.color = color
        circleAreaNode.alpha = 0.5
        circleAreaNode.setScale(0.0)
        circleAreaNode.run(SKAction.repeatForever(circleSequenceAction))
    }
    
    func schemeAvailable(_ scheme: String) -> Bool {
        if let url = URL(string: scheme) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

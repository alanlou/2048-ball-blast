//
//  StoreScene.swift
//  OrbitMerge
//
//  Created by Alan Lou on 2/9/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import SpriteKit
import StoreKit
import Firebase

class StoreScene: SKScene, ControlButtonDelegate, StoreItemDelegate, WatchVideoItemDelegate {
    
    // super node containing the layers
    private let nodeLayer = SKNode()
    private let cameraLayer = SKCameraNode()
    
    // nodes
    private let coinNode: CoinNode
    private let coinNumberNode = MessageNode(message: "", fontName: FontNameType.Montserrat_SemiBold)
    private let titleNode = MessageNode(message: "Skins", fontName: FontNameType.Montserrat_SemiBold)
    private let watchVideoNode: WatchVideoItem
    private let topMaskNode: SKSpriteNode
    private let bottomMaskNode: SKSpriteNode
    private let backButtonNode: ControlButtonNode
    private var watchVideoButtonBelow: ZLSpriteNode
    
    // variables
    private var safeAreaRect: CGRect!
    private var initialTouchPosition: CGPoint?
    private var initialTouchThreshold: CGFloat?
    private var previousTouchPosition: CGPoint?
    private var delta: CGFloat = 0.0
    
    // numbers
    private let universalWidth: CGFloat
    private let cellWidth: CGFloat
    private let cellHeight: CGFloat
    private let leftAndRightPaddings: CGFloat
    private let ballWidth: CGFloat
    private var bottomSafeSets: CGFloat!
    private var topSafeSets: CGFloat!
    private let amountOfMoneyForBall = 100
    private var topSectionSpace: CGFloat!
    private var upAndDownPaddings: CGFloat!
    private var numOfRows: Int!
    
    // for ball selection
    var currentSender: StoreItem?
    
    // booleans
    var isAdReady: Bool = false
    var skipThisTouch: Bool = false
    
    // balls
    var items = ["Simple", "Modern", "Warm", "Bright", "Dark", "Mint"]
    
    // IAP
    var products = [SKProduct]()
    
    // game sounds
    let buttonPressedSound: SKAction = SKAction.playSoundFileNamed(
        "buttonPressed.wav", waitForCompletion: false)
    let addCoinsSound: SKAction = SKAction.playSoundFileNamed(
        "addCoins.m4a", waitForCompletion: false)
    
    var gameSoundOn: Bool {
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
    var coinNumber: Int {
        get {
            if  UserDefaults.standard.object(forKey: "coinNumber") == nil {
                UserDefaults.standard.set(0, forKey: "coinNumber")
            }
            return UserDefaults.standard.integer(forKey: "coinNumber")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "coinNumber")
        }
    }
    var adsHeight: CGFloat {
        get {
            return CGFloat(UserDefaults.standard.float(forKey: "AdsHeight"))
        }
    }
    
    //MARK:- Initialization
    override init(size: CGSize) {
        // pre-defined numbers
        universalWidth = min(size.width, size.height*9.0/16.0)
        cellWidth = universalWidth*0.8
        cellHeight = cellWidth*(223.0/600.0)
        leftAndRightPaddings = max(size.width*1.2*0.06,size.height*0.06*4.0/9.0)
        
        // define nodes
        ballWidth =  min(size.width, size.height*0.6)*0.4*0.1
        coinNode = CoinNode(width: ballWidth*1.2)
        backButtonNode = ControlButtonNode(color: ColorCategory.getTextFontColor(), width: ballWidth*1.4, controlButtonType: ControlButtonType.BackButton)
        topMaskNode = SKSpriteNode(texture: nil, color: ColorCategory.getBackgroundColor(), size: CGSize(width: size.width, height: size.height))
        bottomMaskNode = SKSpriteNode(texture: nil, color: ColorCategory.getBackgroundColor(), size: CGSize(width: size.width, height: size.height))
        
        // define nodes
        let watchVideoNodeHeight = universalWidth*(0.68/3.0)*(133.0/245.0)
        watchVideoNode = WatchVideoItem(color: ColorCategory.getBarTopColor(), frameHeight: watchVideoNodeHeight)
        watchVideoButtonBelow = ZLSpriteNode(height: watchVideoNodeHeight, image: "TopBar", color: ColorCategory.getBarBottomColor())
        
        // initiate
        super.init(size: size)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(addedCoins),
                                               name: Notification.Name(rawValue: "addedCoins"),
                                               object: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override func didMove(to view: SKView) {
        self.backgroundColor = ColorCategory.getBackgroundColor()
        self.view?.isMultipleTouchEnabled = false
        
        var safeSets:UIEdgeInsets
        if #available(iOS 11.0, *) {
            safeSets = view.safeAreaInsets
        } else {
            safeSets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        }
        safeAreaRect = CGRect(x: safeSets.left,
                              y: safeSets.bottom+adsHeight,
                              width: size.width-safeSets.right-safeSets.left,
                              height: size.height-safeSets.top-safeSets.bottom-adsHeight)
        bottomSafeSets = safeSets.bottom
        topSafeSets = safeSets.top
        
        // set up node layer
        nodeLayer.position = CGPoint(x: 0.0, y: 0.0)
        self.addChild(nodeLayer)
        
        // set up camera node
        self.camera = cameraLayer
        self.addChild(cameraLayer) //make the cam a childElement of the scene itself.
        cameraLayer.position = CGPoint(x: size.width/2.0, y: size.height/2.0)
        
        // Add Coin Node & Label
        coinNode.anchorPoint = CGPoint(x:1.0, y:1.0)
        coinNode.position = CGPoint(x: safeAreaRect.width/2.0-ballWidth*0.45, y:size.height/2.0-topSafeSets-ballWidth*0.68)
        coinNode.zPosition = 10000
        cameraLayer.addChild(coinNode)
        
        coinNumberNode.setText(to: "\(self.coinNumber)")
        let coinNumberNodeWidth = coinNode.size.width*4.0
        let coinNumberNodeHeight = coinNode.size.height
        let coinNumberNodeFrame = CGRect(x: safeAreaRect.width*CGFloat(0.5)-coinNumberNodeWidth-ballWidth*CGFloat(2.0),
                                         y: size.height/2.0-topSafeSets-ballWidth*CGFloat(0.68)-coinNode.size.height,
                                         width: coinNumberNodeWidth,
                                         height: coinNumberNodeHeight)
        coinNumberNode.adjustLabelFontSizeToFitRect(rect: coinNumberNodeFrame)
        coinNumberNode.setHorizontalAlignment(mode: SKLabelHorizontalAlignmentMode.right)
        coinNumberNode.zPosition = 10000
        cameraLayer.addChild(coinNumberNode)
        
        // Add Back Button
        backButtonNode.buttonDelegate = self
        backButtonNode.anchorPoint = CGPoint(x:0.0, y:1.0)
        backButtonNode.position = CGPoint(x:-safeAreaRect.width*CGFloat(0.5)+ballWidth*0.4, y:size.height/2.0-topSafeSets-ballWidth*0.1)
        backButtonNode.alpha = 1.0
        backButtonNode.isUserInteractionEnabled = true
        backButtonNode.zPosition = 10000
        cameraLayer.addChild(backButtonNode)
        //print(backButtonNode)
        
        // Add Title
        let titleNodeWidth = safeAreaRect.width/2
        let titleNodeHeight = coinNode.size.height*1.6
        let titleNodeFrame = CGRect(x: 0.0-titleNodeWidth*0.5,
                                    y: size.height/2.0-topSafeSets-titleNodeHeight-coinNumberNodeHeight-CGFloat(8.0*1.6),
                                    width: titleNodeWidth,
                                    height: titleNodeHeight)
        titleNode.setFontColor(color: ColorCategory.getTextFontColor())
        titleNode.adjustLabelFontSizeToFitRect(rect: titleNodeFrame)
        titleNode.setHorizontalAlignment(mode: SKLabelHorizontalAlignmentMode.center)
        //debugDrawArea(rect: coinNumberNodeFrame)
        titleNode.zPosition = 10000
        cameraLayer.addChild(titleNode)
        
        // define paddings
        upAndDownPaddings = ballWidth
        
        // Add Seperator
        topSectionSpace = (coinNumberNode.frame.maxY-titleNode.frame.minY)+upAndDownPaddings*CGFloat(4.0)+watchVideoNode.size.height
        let px = 1.0 / UIScreen.main.scale
        let line = SKSpriteNode(color: ColorCategory.getLineColor(), size: CGSize(width:safeAreaRect.width-2.0*leftAndRightPaddings, height:4*px))
        line.name = "seperator"
        line.zPosition = 10000
        line.position = CGPoint(x:0.0,
                                y:size.height/2.0-topSafeSets-topSectionSpace)
        cameraLayer.addChild(line)
        
        // add top mask
        topMaskNode.anchorPoint = CGPoint(x:0.0, y:0.0)
        topMaskNode.zPosition = 5000
        topMaskNode.position = CGPoint(x:-safeAreaRect.width/2.0, y:size.height/2.0-topSafeSets-topSectionSpace)
        cameraLayer.addChild(topMaskNode)
        
        bottomMaskNode.anchorPoint = CGPoint(x:0.0, y:1.0)
        bottomMaskNode.zPosition = 5000
        bottomMaskNode.position = CGPoint(x:-safeAreaRect.width/2.0, y:safeAreaRect.minY-self.size.height/2.0)
        cameraLayer.addChild(bottomMaskNode)
        
        // Set up watch video item
        addWatchVideoItem()
        
        // Set up store items
        addStoreItems()
        
    }
    
    func addStoreItems() {
        // create the store items
        numOfRows = Int(items.count)
        
        // get current selected ball
        let decoded  = UserDefaults.standard.object(forKey: "SelectedMode") as! Data
        let currentSelectedMode = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! ModeItem
        let currentSelectedIdentifier = currentSelectedMode.identifier
        
        for row in 0 ..< numOfRows {
            let identifier = items[row]
            let storeItem = StoreItem(frameWidth: universalWidth*0.8)
            storeItem.storeItemDelegate = self
            // calculate position
            let xPosition = size.width*0.5
            let yOffset = upAndDownPaddings*(1.0+CGFloat(row))+cellHeight*(1.0+2.0*CGFloat(row))/2.0
            let yPosition = self.size.height-topSafeSets-topSectionSpace-yOffset
            // add store items
            storeItem.position = CGPoint(x:xPosition, y:yPosition)
            storeItem.name = identifier
            storeItem.setupStoreItem(as: identifier)
            storeItem.zPosition = 10
            nodeLayer.addChild(storeItem)
            // set frame
            if (identifier == currentSelectedIdentifier) {
                // set selection
                self.setFrameToThisItem(target: storeItem)
            }
        }
    }
    
    func addWatchVideoItem() {
        // calculate position
        let xPosition = CGFloat(0.0)
        let yPosition = titleNode.frame.minY-upAndDownPaddings*CGFloat(1.5)-watchVideoNode.size.height*CGFloat(0.5)
        // add watch video items
        watchVideoNode.position = CGPoint(x:CGFloat(xPosition), y:CGFloat(yPosition))
        watchVideoNode.zPosition = 10000
        watchVideoNode.watchVideoItemDelegate = self
        cameraLayer.addChild(watchVideoNode)
        
        watchVideoNode.setInitialPosition(to: watchVideoNode.position)
        watchVideoButtonBelow.position = CGPoint(x: xPosition, y: yPosition-watchVideoNode.size.height*0.08)
        watchVideoButtonBelow.zPosition = 9900
        cameraLayer.addChild(watchVideoButtonBelow)
        
        if isAdReady {
            watchVideoNode.alpha = 1.0
            watchVideoButtonBelow.alpha = 1.0
        } else {
            watchVideoNode.alpha = 0.5
            watchVideoButtonBelow.alpha = 0.5
        }
    }
    
    func getStoreItemAtPoint(at point: CGPoint) -> StoreItem? {
        
        let xPosition = point.x
        let yPosition = point.y
        let yOffset = self.size.height-topSafeSets-topSectionSpace-yPosition
        
        // calculate row and col
        var col: Int? = nil
        if xPosition >= self.size.width*0.5-universalWidth*0.4,
            xPosition <= self.size.width*0.5+universalWidth*0.4 {
            col = 0
        }
        
        var row: Int? = nil
        for rowIter in 0 ..< numOfRows{
            if yOffset >= upAndDownPaddings*(CGFloat(rowIter)+CGFloat(1.0))+cellHeight*CGFloat(rowIter),
                yOffset <= upAndDownPaddings*(CGFloat(rowIter)+CGFloat(1.0))+cellHeight*(CGFloat(rowIter)+CGFloat(1.0)) {
                row = rowIter
            }
        }
        
        if let _=col, let row=row {
            let identifier = items[row]
            let storeItem = nodeLayer.childNode(withName: identifier) as! StoreItem
            
            return storeItem
        } else {
            return nil
        }
        
    }
    
    func updateCoinNumber() {
        coinNumberNode.setCoinNumber(to: "\(coinNumber)")
    }
    
    //MARK:- ControlButtonDelegate
    func controlButtonWasPressed(sender: ControlButtonNode) {
        if sender.getControlButtonType() == ControlButtonType.BackButton {
            // play sound
            if gameSoundOn{
                self.run(buttonPressedSound)
            }
            
            if view != nil {
                let transition:SKTransition = SKTransition.fade(withDuration: 0.5)
                let menuScene = MenuScene(size: self.size)
                menuScene.isAdReady = self.isAdReady
                self.view?.presentScene(menuScene, transition: transition)
            }
            return
            
        }
    }
    
    //MARK:- StoreItemDelegate
    func modeWasSelected(sender: StoreItem) {
        // play sound
        if gameSoundOn{
            self.run(buttonPressedSound)
        }
        
        currentSender = sender
        
        // get ball items
        let nextSelectedMode: ModeItem = sender.getStoreItem()
        
        // Case 1: Change to an already bought ball
        if nextSelectedMode.isBought{
            
            // synchronize
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: nextSelectedMode)
            UserDefaults.standard.set(encodedData, forKey: "SelectedMode")
            
            // reload data
            sender.setupStoreItem(as: sender.identifier)
            
            // reload table frame
            for row in 0 ..< numOfRows {
                let identifier = items[row]
                if identifier == nextSelectedMode.identifier {
                    self.setFrameToThisItem(target: sender)
                }
            }
        } else {
            // Case 4:buy a new ball
            if coinNumber >= amountOfMoneyForBall {
                let userInfoDict:[String: String] = ["forButton": "buyNewBall"]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "displayAlertMessage"), object: nil, userInfo: userInfoDict)
            } else {
                // Case 3: not enough money to buy new ball
                let userInfoDict:[String: String] = ["forButton": "notEnoughCoins"]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "displayAlertMessage"), object: nil, userInfo: userInfoDict)
                
            }
        }
        
    }
    
    
    //MARK:- WatchVideoItemDelegate
    func watchVideoWasSelected(sender: WatchVideoItem) {
        
        // play sound
        if gameSoundOn{
            self.run(buttonPressedSound)
        }
        
        print("WATCH VIDEO!")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "runRewardAds"), object: nil)
    }
    
    // MARK:- Touch Events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // reset delta
        skipThisTouch = false
        delta = 0
        
        initialTouchPosition = touches.first!.positionOnScene
        initialTouchThreshold = initialTouchPosition!.y+size.height/2.0-cameraLayer.position.y
        previousTouchPosition = touches.first!.positionOnScene
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let currentTouchPosition = touches.first!.positionOnScene
        delta = currentTouchPosition.y - previousTouchPosition!.y
        previousTouchPosition = currentTouchPosition
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let currentTouchPosition = touches.first!.positionOnScene
        
        // if no move -> touch the item
        if distance(currentTouchPosition, initialTouchPosition!) < 1.0 {
            // Case 1. check if store item is touched
            let storeItemTemp = getStoreItemAtPoint(at: currentTouchPosition)
            if let storeItem = storeItemTemp, !skipThisTouch {
                storeItem.getTouched()
            }
        }
        
        // clear variables
        initialTouchPosition = nil
        previousTouchPosition = nil
        initialTouchThreshold = nil
    }
    
    
    //MARK:- Update event
    override func update(_ currentTime: TimeInterval) {
        // stop when touch is out of area
        if let initialTouchThreshold = initialTouchThreshold, initialTouchThreshold > self.size.height-topSectionSpace {
            skipThisTouch = true
            return
        }
        
        if skipThisTouch {
            return
        }
        
        // stop when moving too slow
        if abs(delta) < 0.1 {
            delta = 0
            return
        }
        
        // calculate new camera position
        let timeConsistencyFactor: CGFloat = 0.92 // 0.0 to 1.0. higher number means the inertia lasts longer
        let cameraLagFactor: CGFloat = 1.0
        delta = self.delta * timeConsistencyFactor
        
        var newCameraPositionY = cameraLayer.position.y - delta*cameraLagFactor
        // update the prior touch positions with camera movement
        if let previousTouchPosition = previousTouchPosition {
            self.previousTouchPosition!.y = previousTouchPosition.y - delta*cameraLagFactor
        }
        
        
        // bounce back if out of boundary
        let cameraMaxY = self.size.height/2.0
        let yOffset = upAndDownPaddings*(1.0+CGFloat(numOfRows))+cellHeight*CGFloat(numOfRows)
        
        let cameraMinY = cameraMaxY-yOffset+size.height-topSafeSets-topSectionSpace-adsHeight-bottomSafeSets
        
        if newCameraPositionY > cameraMaxY {
            newCameraPositionY = newCameraPositionY - (newCameraPositionY-cameraMaxY)*0.5
        }
        
        if newCameraPositionY < cameraMinY {
            newCameraPositionY = newCameraPositionY + (cameraMinY-newCameraPositionY)*0.5
        }
        
        // move camera
        cameraLayer.position.y = newCameraPositionY
        
    }
    
    //MARK:- Helper Functions
    func buyANewMode() {
        if let sender = currentSender {
            // get ball items
            let nextSelectedMode: ModeItem = sender.getStoreItem()
            
            nextSelectedMode.isBought = true
            self.coinNumber = self.coinNumber - self.amountOfMoneyForBall
            self.updateCoinNumber()
            
            // play sound
            if gameSoundOn{
                self.run(addCoinsSound)
            }
            
            // synchronize
            var encodedData = NSKeyedArchiver.archivedData(withRootObject: nextSelectedMode)
            UserDefaults.standard.set(encodedData, forKey: nextSelectedMode.identifier)
            encodedData = NSKeyedArchiver.archivedData(withRootObject: nextSelectedMode)
            UserDefaults.standard.set(encodedData, forKey: "SelectedMode")
            
            // reload data
            sender.setupStoreItem(as: sender.identifier)
            
            // reload table frame
            for row in 0 ..< numOfRows {
                let identifier = items[row]
                let storeItem = nodeLayer.childNode(withName: identifier) as! StoreItem
                if identifier == nextSelectedMode.identifier {
                    self.setFrameToThisItem(target: storeItem)
                }
            }
        }
    }
    
    func updateUIColors() {
        // 1. background
        self.backgroundColor = ColorCategory.getBackgroundColor()
        self.topMaskNode.color =  ColorCategory.getBackgroundColor()
        self.bottomMaskNode.color =  ColorCategory.getBackgroundColor()
        // 2. title node
        self.titleNode.setFontColor(color: ColorCategory.getTextFontColor())
        
        // 3. coin number
        self.coinNumberNode.setFontColor(color: ColorCategory.getTextFontColor())
        
        // 4. WatchVideoNode
        self.watchVideoNode.updateColor()
        self.watchVideoButtonBelow.changeColor(to: ColorCategory.getBarBottomColor())
        
        // 5. back button
        backButtonNode.changeColor(to: ColorCategory.getTextFontColor())
        
        // 6. seperator
        if let seperator = cameraLayer.childNode(withName: "seperator") as? SKSpriteNode {
            seperator.color = ColorCategory.getLineColor()
        }
    }
    
    func setFrameToThisItem(target: StoreItem) {
        for child in nodeLayer.children {
            if let storeItem = child as? StoreItem {
                print("HEY")
                print(storeItem.identifier )
                storeItem.removeInUseLabel()
            }
        }
        
        target.setFrameToThisItem()
        
        updateUIColors()
    }
    
    
    func performAdsAddCoins() {
        
        // Log Event
        Analytics.logEvent("ad_add_coins", parameters: [:])
        
        self.coinNumber = coinNumber+20
        coinNumberNode.setCoinNumber(to: "\(coinNumber)")
        
        // play sound
        if gameSoundOn {
            self.run(addCoinsSound)
        }
    }
    
    func enableWatchVideo() {
        isAdReady = true
        
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
        watchVideoNode.run(fadeIn)
        watchVideoButtonBelow.run(fadeIn)
        
    }
    
    func disableWatchVideo() {
        //print(disableWatchVideo)
        isAdReady = false
        
        let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: 0.2)
        watchVideoNode.run(fadeOut)
        watchVideoButtonBelow.run(fadeOut)
    }
    
    func goToFacebook() {
        let fbInstalled = schemeAvailable("fb://")
        
        if fbInstalled {
            // If user facebook installed
            guard let url = URL(string: "fb://profile/349909612079389") else {
                return
            }
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
            // If user does not have twitter installed
            guard let url = URL(string: "https://www.facebook.com/RawwrStudios") else {
                return
            }
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func goToTwitter() {
        let twInstalled = schemeAvailable("twitter://")
        
        if twInstalled {
            // If user twitter installed
            guard let url = URL(string: "twitter://user?screen_name=rawwrstudios") else {
                return
            }
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
            // If user does not have twitter installed
            guard let url = URL(string: "https://mobile.twitter.com/rawwrstudios") else {
                return
            }
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @objc func addedCoins() {
        coinNumberNode.setCoinNumber(to: "\(coinNumber)")
        
        // play sound
        if gameSoundOn{
            self.run(addCoinsSound)
        }
    }
    
    func schemeAvailable(_ scheme: String) -> Bool {
        if let url = URL(string: scheme) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    
    func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }
    
    
}

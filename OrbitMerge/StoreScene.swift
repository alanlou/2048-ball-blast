//
//  StoreScene.swift
//  Bouncing
//
//  Created by Alan Lou on 2/9/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import SpriteKit
import StoreKit

class StoreScene: SKScene, ControlButtonDelegate, StoreItemDelegate, IAPItemDelegate, ShopSelectionItemDelegate {
    
    
    // super node containing the layers
    private let nodeLayer = SKNode()
    private let cameraLayer = SKCameraNode()
    
    // nodes
    private let frameNode: SKSpriteNode
    private let coinNode: CoinNode
    private let coinNumberNode = MessageNode(message: "")
    private let titleNode = MessageNode(message: "SHOP")
    private let watchVideoNode: WatchVideoItem
    
    // variables
    private var safeAreaRect: CGRect!
    private var initialTouchPosition: CGPoint?
    private var initialTouchThreshold: CGFloat?
    private var previousTouchPosition: CGPoint?
    private var delta: CGFloat = 0.0
    
    // numbers
    private let leftAndRightPaddings: CGFloat
    private let numberOfItemsPerRow: CGFloat
    private let cellWidth: CGFloat
    private let cellHeight: CGFloat
    private let ballWidth: CGFloat
    private var bottomSafeSets: CGFloat!
    private var topSafeSets: CGFloat!
    private let selectionSectionSpace: CGFloat
    private let amountOfMoneyForBall = 100
    private var topSectionSpace: CGFloat!
    private var upAndDownPaddings: CGFloat!
    private var numOfRows: Int!
    private var selectedBallKey: String
    
    // for ball selection
    var currentSender: StoreItem?
    
    // booleans
    var isAdReady: Bool = false
    var skipThisTouch: Bool = false
    
    // balls
    var items = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32"]
    
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
    // which tab is selected
    private var _selectionIndex: Int = 1
    var selectionIndex: Int {
        get {
            return _selectionIndex
        }
        set {
            _selectionIndex = newValue
            self.selectedBallKey = "SelectedBall\(newValue)"
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
        numberOfItemsPerRow = 3.0
        leftAndRightPaddings = max(size.width*1.2*0.06,size.height*0.06*4.0/9.0)
        cellWidth = (size.width-leftAndRightPaddings*(numberOfItemsPerRow+1))/numberOfItemsPerRow
        cellHeight = cellWidth*0.8
        
        // define nodes
        ballWidth =  min(size.width, size.height*0.6)*0.4*0.1
        selectionSectionSpace = ballWidth*1.5
        coinNode = CoinNode(color: ColorCategory.InitialBallColor, width: ballWidth)
        
        // define frame
        let frameLineWidth: CGFloat = ballWidth*0.2
        let frameSize = CGSize(width: cellWidth+frameLineWidth, height: cellHeight+frameLineWidth)
        frameNode = SKSpriteNode(texture: nil, color: .clear, size: frameSize)
        frameNode.colorBlendFactor = 1.0
        frameNode.color = .clear
        
        // set selectedBallKey
        if  UserDefaults.standard.object(forKey: "selectionIndex") == nil {
            UserDefaults.standard.set(1, forKey: "selectionIndex")
        }
        selectedBallKey = "SelectedBall\(UserDefaults.standard.integer(forKey: "selectionIndex"))"
        
        // define nodes
        watchVideoNode = WatchVideoItem(color: ColorCategory.getCellBackgroundColor(), frameSize: CGSize(width: cellWidth*3.0, height: cellWidth*0.5))
        
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
        coinNode.position = CGPoint(x: safeAreaRect.width/2.0-ballWidth*0.4, y:size.height/2.0-topSafeSets-ballWidth*0.7)
        coinNode.zPosition = 10000
        cameraLayer.addChild(coinNode)
        
        coinNumberNode.setText(to: "\(self.coinNumber)")
        let coinNumberNodeWidth = coinNode.size.width*4.0
        let coinNumberNodeHeight = coinNode.size.height+4.0
        let coinNumberNodeFrame = CGRect(x: safeAreaRect.width*CGFloat(0.5)-coinNumberNodeWidth-ballWidth*CGFloat(1.8),
                                         y: size.height/2.0-topSafeSets-ballWidth*CGFloat(1.7)-2.0,
                                         width: coinNumberNodeWidth,
                                         height: coinNumberNodeHeight)
        coinNumberNode.adjustLabelFontSizeToFitRect(rect: coinNumberNodeFrame)
        coinNumberNode.setHorizontalAlignment(mode: SKLabelHorizontalAlignmentMode.right)
        coinNumberNode.zPosition = 10000
        cameraLayer.addChild(coinNumberNode)
        
        // Add Back Button
        let backButtonNode = ControlButtonNode(color: ColorCategory.getControlButtonColor(), width: ballWidth*1.6, controlButtonType: ControlButtonType.BackButton)
        backButtonNode.buttonDelegate = self
        backButtonNode.anchorPoint = CGPoint(x:0.0, y:1.0)
        backButtonNode.position = CGPoint(x:-safeAreaRect.width*CGFloat(0.5), y:size.height/2.0-topSafeSets)
        backButtonNode.alpha = 1.0
        backButtonNode.isUserInteractionEnabled = true
        backButtonNode.zPosition = 10000
        cameraLayer.addChild(backButtonNode)
        //print(backButtonNode)
        
        // Add Title
        let titleNodeWidth = safeAreaRect.width/2
        let titleNodeHeight = coinNode.size.height*1.8
        let titleNodeFrame = CGRect(x: 0.0-titleNodeWidth*0.5,
                                    y: size.height/2.0-topSafeSets-titleNodeHeight-coinNumberNodeHeight-CGFloat(8.0*1.8),
                                    width: titleNodeWidth,
                                    height: titleNodeHeight)
        titleNode.adjustLabelFontSizeToFitRect(rect: titleNodeFrame)
        titleNode.setHorizontalAlignment(mode: SKLabelHorizontalAlignmentMode.center)
        //debugDrawArea(rect: coinNumberNodeFrame)
        titleNode.zPosition = 10000
        cameraLayer.addChild(titleNode)
        
        // define paddings
        upAndDownPaddings = ballWidth
        
        // Add Seperator
        topSectionSpace = (coinNumberNode.frame.maxY-titleNode.frame.minY)+upAndDownPaddings*4.0+cellWidth+8.0+selectionSectionSpace
        let px = 1.0 / UIScreen.main.scale
        let line = SKSpriteNode(color: ColorCategory.getLineColor(), size: CGSize(width:safeAreaRect.width-2.0*leftAndRightPaddings, height:4*px))
        line.zPosition = 10000
        line.position = CGPoint(x:0.0,
                                y:size.height/2.0-topSafeSets-topSectionSpace)
        cameraLayer.addChild(line)
        
        // add top mask
        let topMaskNode = SKSpriteNode(texture: nil, color: ColorCategory.getBackgroundColor(), size: CGSize(width: safeAreaRect.width, height: safeAreaRect.height))
        topMaskNode.anchorPoint = CGPoint(x:0.0, y:0.0)
        topMaskNode.zPosition = 5000
        topMaskNode.position = CGPoint(x:-safeAreaRect.width/2.0, y:size.height/2.0-topSafeSets-topSectionSpace)
        cameraLayer.addChild(topMaskNode)
        
        // Add frame
        nodeLayer.addChild(frameNode)
        
        // Set up IAP items
        addIAPItems()
        
        // Set up watch video item
        addWatchVideoItem()
        
        // Set up store items
        addStoreItems()
        
        // Set up shop selection items
        addShopSelectionItems()
        
    }
    
    func addStoreItems() {
        // create the store items
        numOfRows = Int(ceilf(Float(CGFloat(items.count)/CGFloat(numberOfItemsPerRow))))
        
        // get current selected ball
        let decoded  = UserDefaults.standard.object(forKey: selectedBallKey) as! Data
        let currentSelectedBall = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! BallItem
        let currentSelectedIdentifier = currentSelectedBall.identifier
        
        for row in 0 ..< numOfRows {
            for col in 0 ..< Int(numberOfItemsPerRow) {
                let identifier = items[row*3+col]
                let storeItem = StoreItem(color: ColorCategory.getCellBackgroundColor(), frameSize: CGSize(width: cellWidth, height: cellHeight), ballWidth: ballWidth)
                storeItem.storeItemDelegate = self
                // calculate position
                let xPosition = leftAndRightPaddings*(1.0+CGFloat(col))+cellWidth*(1.0+2.0*CGFloat(col))/2.0
                let yOffset = upAndDownPaddings*(1.0+CGFloat(row))+cellHeight*(1.0+2.0*CGFloat(row))/2.0
                let yPosition = self.size.height-topSafeSets-topSectionSpace-yOffset
                // add store items
                storeItem.position = CGPoint(x:xPosition, y:yPosition)
                storeItem.name = "Ball\(identifier)"
                storeItem.setupStoreItem(as: "Ball\(identifier)")
                storeItem.zPosition = 10
                nodeLayer.addChild(storeItem)
                // set frame
                if "Ball\(identifier)" == currentSelectedIdentifier {
                    frameNode.color = ColorCategory.InitialBallColor
                    frameNode.position = storeItem.position
                }
            }
        }
    }
    
    func addIAPItems() {
        // create the IAP items
        for col in 0 ..< 3 {
            var numOfBalls = 0
            if col == 0 {
                numOfBalls = 200
            } else if col == 1 {
                numOfBalls = 500
            } else if col == 2 {
                numOfBalls = 900
            }
            
            let iapItem = IAPItem(color: ColorCategory.getCellBackgroundColor(), frameSize: CGSize(width: cellWidth*0.9, height: cellWidth*0.5), ballWidth: ballWidth, numOfBalls: numOfBalls)
            
            // calculate position
            let xPosition = leftAndRightPaddings*(1.0+CGFloat(col))+cellWidth*(1.0+2.0*CGFloat(col))/2.0 - size.width*0.5
            let yPosition = titleNode.frame.minY-upAndDownPaddings*CGFloat(1.5)-cellWidth*CGFloat(0.30)
            // add store items
            iapItem.position = CGPoint(x:xPosition, y:yPosition)
            iapItem.zPosition = 10000
            iapItem.name = "iapItem\(col)"
            iapItem.IAPItemDelegate = self
            cameraLayer.addChild(iapItem)
            
        }
    }
    
    func addShopSelectionItems() {
        // create the shop selection items
        for col in 0 ..< 3 {
            let tempSelectionIndex = col+1
            
            let shopSelectionItem = ShopSelectionItem(color: ColorCategory.getLineColor(), frameSize: CGSize(width: cellWidth*0.9, height: selectionSectionSpace), selectionIndex: tempSelectionIndex)
            // if not selected, fade alpha
            if tempSelectionIndex != selectionIndex {
                shopSelectionItem.alpha = 0.25
            }
            
            // calculate position
            let xPosition = leftAndRightPaddings*(1.0+CGFloat(col))+cellWidth*(1.0+2.0*CGFloat(col))/2.0 - size.width*0.5
            let yPosition = size.height/2.0-topSafeSets-topSectionSpace+selectionSectionSpace*CGFloat(0.5)
            // add store items
            shopSelectionItem.position = CGPoint(x:xPosition, y:yPosition)
            shopSelectionItem.zPosition = 10000
            shopSelectionItem.name = "shopSelectionItem\(col)"
            shopSelectionItem.shopSelectionItemDelegate = self
            cameraLayer.addChild(shopSelectionItem)
            
        }
    }
    
    func addWatchVideoItem() {
        // calculate position
        let xPosition = 0.0
        let yPosition = titleNode.frame.minY-upAndDownPaddings*CGFloat(2.5)-cellWidth*CGFloat(0.5)-watchVideoNode.size.height*CGFloat(0.5)
        // add watch video items
        watchVideoNode.position = CGPoint(x:CGFloat(xPosition), y:CGFloat(yPosition))
        watchVideoNode.zPosition = 10000
        watchVideoNode.name = "watchVideoItem"
        if isAdReady {
            watchVideoNode.alpha = 1.0
        } else {
            watchVideoNode.alpha = 0.5
        }
        cameraLayer.addChild(watchVideoNode)
    }
    
    func getStoreItemAtPoint(at point: CGPoint) -> StoreItem? {
        
        let xPosition = point.x
        let yPosition = point.y
        let yOffset = self.size.height-topSafeSets-topSectionSpace-yPosition
        
        // calculate row and col
        var col: Int? = nil
        for colIter in 0 ..< Int(numberOfItemsPerRow) {
            if xPosition >= leftAndRightPaddings*(CGFloat(colIter)+CGFloat(1.0))+cellWidth*CGFloat(colIter),
                xPosition <= leftAndRightPaddings*(CGFloat(colIter)+CGFloat(1.0))+cellWidth*(CGFloat(colIter)+CGFloat(1.0)) {
                col = colIter
            }
        }
        
        var row: Int? = nil
        for rowIter in 0 ..< numOfRows{
            if yOffset >= upAndDownPaddings*(CGFloat(rowIter)+CGFloat(1.0))+cellHeight*CGFloat(rowIter),
                yOffset <= upAndDownPaddings*(CGFloat(rowIter)+CGFloat(1.0))+cellHeight*(CGFloat(rowIter)+CGFloat(1.0)) {
                row = rowIter
            }
        }
        
        if let col=col, let row=row {
            let identifier = items[row*3+col]
            let storeItem = nodeLayer.childNode(withName: "Ball\(identifier)") as! StoreItem
            
            return storeItem
        } else {
            return nil
        }
        
    }
    
    
    func getIAPItemAtPoint(at point: CGPoint) -> IAPItem? {
        // calculate position
        let xPosition = point.x-cameraLayer.position.x
        let yPosition = point.y-cameraLayer.position.y
        
        // calculate row and col
        var col: Int? = nil
        for colIter in 0 ..< Int(numberOfItemsPerRow) {
            let iapXPosition = leftAndRightPaddings*(1.0+CGFloat(colIter))+cellWidth*(1.0+2.0*CGFloat(colIter))/2.0 - size.width*0.5
            if xPosition >= iapXPosition-cellWidth*0.45,
                xPosition <= iapXPosition+cellWidth*0.45 {
                col = colIter
            }
        }
        
        var row: Int? = nil
        let iapYPosition = titleNode.frame.minY-upAndDownPaddings*CGFloat(1.5)-cellWidth*CGFloat(0.25)
        if yPosition >= iapYPosition-cellWidth*0.25,
            yPosition <= iapYPosition+cellWidth*0.25 {
            row = 0
        }
        
        if let col=col, let _=row {
            let iapItem = cameraLayer.childNode(withName: "iapItem\(col)") as! IAPItem
            return iapItem
        } else {
            return nil
        }
    }
    
    
    func getShopSelectionItemAtPoint(at point: CGPoint) -> ShopSelectionItem? {
        // calculate position
        let xPosition = point.x-cameraLayer.position.x
        let yPosition = point.y-cameraLayer.position.y
        
        // calculate row and col
        var col: Int? = nil
        for colIter in 0 ..< Int(numberOfItemsPerRow) {
            let iapXPosition = leftAndRightPaddings*(1.0+CGFloat(colIter))+cellWidth*(1.0+2.0*CGFloat(colIter))/2.0 - size.width*0.5
            if xPosition >= iapXPosition-cellWidth*0.45,
                xPosition <= iapXPosition+cellWidth*0.45 {
                col = colIter
            }
        }
        
        var row: Int? = nil
        let shopSelectionYPosition = size.height/2.0-topSafeSets-topSectionSpace+selectionSectionSpace*CGFloat(0.5)
        if yPosition >= shopSelectionYPosition-selectionSectionSpace*0.5,
            yPosition <= shopSelectionYPosition+selectionSectionSpace*0.5 {
            row = 0
        }
        
        if let col=col, let _=row {
            // play sound
            if gameSoundOn{
                self.run(buttonPressedSound)
            }
            
            let shopSelectionItem = cameraLayer.childNode(withName: "shopSelectionItem\(col)") as! ShopSelectionItem
            
            return shopSelectionItem
        } else {
            return nil
        }
    }
    
    func checkIfPlayVideoAtPoint(at point: CGPoint) {
        
        var willWatchVideo = true
        // calculate position
        let xPosition = point.x-cameraLayer.position.x
        let yPosition = point.y-cameraLayer.position.y
        
        // calculate row and col
        if xPosition < -cellWidth*1.5 || xPosition > cellWidth*1.5 {
            willWatchVideo = false
        }
        
        let videoYPosition = titleNode.frame.minY-upAndDownPaddings*CGFloat(2.5)-cellWidth*CGFloat(0.5)-cellWidth*CGFloat(0.25)
        if yPosition < videoYPosition-cellWidth*0.25 || yPosition > videoYPosition+cellWidth*0.25 {
            willWatchVideo = false
        }
        
        if willWatchVideo {
            // play sound
            if gameSoundOn{
                self.run(buttonPressedSound)
            }
            
            //print("WATCH VIDEO!")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "runRewardAds"), object: nil)
        }
    }
    
    func updateCoinNumber() {
        coinNumberNode.setScore(to: "\(coinNumber)")
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
                let gameScene = GameScene(size: self.size)
                gameScene.isAdReady = self.isAdReady
                self.view?.presentScene(gameScene, transition: transition)
            }
            return
            
        }
    }
    
    //MARK:- StoreItemDelegate
    func ballWasSelected(sender: StoreItem) {
        // play sound
        if gameSoundOn{
            self.run(buttonPressedSound)
        }
        
        currentSender = sender
        
        // get ball items
        let nextSelectedBall: BallItem = sender.getStoreItem()
        
        // Case 1: Change to an already bought ball
        if nextSelectedBall.isBought{
            
            // synchronize
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: nextSelectedBall)
            UserDefaults.standard.set(encodedData, forKey: selectedBallKey)
            
            // reload data
            self.removeAllStoreItemActions()
            sender.setupStoreItem(as: sender.identifier)
            
            // reload table frame
            for row in 0 ..< numOfRows {
                for col in 0 ..< Int(numberOfItemsPerRow) {
                    let identifier = items[row*3+col]
                    if "Ball\(identifier)" == nextSelectedBall.identifier {
                        self.setFrameToThisItem(target: sender)
                    }
                }
            }
        } else {
            // Case 2. Facebook -> 3
            if sender.identifier == "Ball3" {
                goToFacebook()
                let wait = SKAction.wait(forDuration: 0.5)
                self.run(wait, completion: {[weak self] in
                    self?.getAFreeBall()
                })
                return
            }
            
            // Case 3. Twitter -> 4
            if sender.identifier == "Ball4" {
                goToTwitter()
                let wait = SKAction.wait(forDuration: 0.5)
                self.run(wait, completion: {[weak self] in
                    self?.getAFreeBall()
                })
                return
            }
            
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
    
    
    //MARK:- IAPItemDelegate
    func iapWasSelected(sender: IAPItem) {
        
        // play sound
        if gameSoundOn{
            self.run(buttonPressedSound)
        }
        
        let iapItem = sender
        
        let numOfBalls = iapItem.getNumOfBalls()
        //print(numOfBalls)
        var iapIndex = 1
        var iapIdentifier = ""
        if numOfBalls == 200 {
            iapIndex = 1
            iapIdentifier = IAPProducts.Ring200
        } else if numOfBalls == 500 {
            iapIndex = 2
            iapIdentifier = IAPProducts.Ring500
        } else if numOfBalls == 900 {
            iapIndex = 3
            iapIdentifier = IAPProducts.Ring900
        }
        
        if !IAPHelper.canMakePayments() {
            let userInfoDict:[String: String] = ["forButton": "iapfail"]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "displayAlertMessage"), object: nil, userInfo: userInfoDict)
        }
        
        products = []
        IAPProducts.store.requestProducts{success, products in
            if success {
                
                // no enough iap
                if products == nil || products?.count != 4 {
                    let userInfoDict:[String: String] = ["forButton": "iapfail"]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "displayAlertMessage"), object: nil, userInfo: userInfoDict)
                    return
                }
                self.products = products!
                
                // buy selected product
                for index in 0..<4 {
                    let thisProduct = self.products[index] as SKProduct
                    if thisProduct.productIdentifier == iapIdentifier {
                        IAPProducts.store.buyProduct(thisProduct)
                        return
                    }
                }
                
            }
        }
    }
    
    //MARK:- ShopSelectionItemDelegate
    func shopSelectionWasSelected(sender: ShopSelectionItem) {
        //print("shopSelectionWasSelected")
        self.selectionIndex = sender.getSelectionIndex()
        
        for col in 0 ..< 3 {
            let tempSelectionIndex = col+1
            let shopSelectionItem = cameraLayer.childNode(withName: "shopSelectionItem\(col)") as! ShopSelectionItem
            
            // animate
            let fadeIn = SKAction.fadeIn(withDuration: 0.25)
            let fadeOut = SKAction.fadeAlpha(to: 0.25, duration: 0.25)
            fadeIn.timingMode = .easeOut
            fadeOut.timingMode = .easeOut
            
            if selectionIndex == tempSelectionIndex {
                shopSelectionItem.run(fadeIn)
            } else {
                shopSelectionItem.run(fadeOut)
            }
        }
        
        //print("HERE")
        //print(self.selectionIndex)
        let decoded  = UserDefaults.standard.object(forKey: selectedBallKey) as! Data
        let currentSelectedBall = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! BallItem
        let currentSelectedIdentifier = currentSelectedBall.identifier
        
        // reload table frame
        for row in 0 ..< numOfRows {
            for col in 0 ..< Int(numberOfItemsPerRow) {
                let identifier = items[row*3+col]
                let storeItem = nodeLayer.childNode(withName: "Ball\(identifier)") as! StoreItem
                //print(identifier)
                //print(currentSelectedIdentifier)
                if "Ball\(identifier)" == currentSelectedIdentifier {
                    frameNode.color = ColorCategory.InitialBallColor
                    frameNode.position = storeItem.position
                }
            }
        }
        
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
            // Case 2. check if iap item is touched
            let iapItemTemp = getIAPItemAtPoint(at: currentTouchPosition)
            if let iapItem = iapItemTemp {
                iapItem.getTouched()
            }
            // Case 3. check if video item is touched
            checkIfPlayVideoAtPoint(at: currentTouchPosition)
            // Case 4. check if shop selection item is touched
            let shopSelectionItemAtPoint = getShopSelectionItemAtPoint(at: currentTouchPosition)
            if let shopSelectionItemAtPoint = shopSelectionItemAtPoint {
                shopSelectionItemAtPoint.getTouched()
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
    func buyANewBall() {
        if let sender = currentSender {
            // get ball items
            let nextSelectedBall: BallItem = sender.getStoreItem()
            
            nextSelectedBall.isBought = true
            self.coinNumber = self.coinNumber - self.amountOfMoneyForBall
            self.updateCoinNumber()
            
            // play sound
            if gameSoundOn{
                self.run(addCoinsSound)
            }
            
            // synchronize
            var encodedData = NSKeyedArchiver.archivedData(withRootObject: nextSelectedBall)
            UserDefaults.standard.set(encodedData, forKey: nextSelectedBall.identifier)
            encodedData = NSKeyedArchiver.archivedData(withRootObject: nextSelectedBall)
            UserDefaults.standard.set(encodedData, forKey: selectedBallKey)
            
            // reload data
            self.removeAllStoreItemActions()
            sender.setupStoreItem(as: sender.identifier)
            
            // reload table frame
            for row in 0 ..< numOfRows {
                for col in 0 ..< Int(numberOfItemsPerRow) {
                    let identifier = items[row*3+col]
                    let storeItem = nodeLayer.childNode(withName: "Ball\(identifier)") as! StoreItem
                    if "Ball\(identifier)" == nextSelectedBall.identifier {
                        self.setFrameToThisItem(target: storeItem)
                    }
                }
            }
        }
    }
    
    func getAFreeBall() {
        if let sender = currentSender {
            // get ball items
            let nextSelectedBall: BallItem = sender.getStoreItem()
            
            nextSelectedBall.isBought = true
            
            // synchronize
            var encodedData = NSKeyedArchiver.archivedData(withRootObject: nextSelectedBall)
            UserDefaults.standard.set(encodedData, forKey: nextSelectedBall.identifier)
            encodedData = NSKeyedArchiver.archivedData(withRootObject: nextSelectedBall)
            UserDefaults.standard.set(encodedData, forKey: selectedBallKey)
            
            // reload data
            self.removeAllStoreItemActions()
            sender.setupStoreItem(as: sender.identifier)
            
            // reload table frame
            for row in 0 ..< numOfRows {
                for col in 0 ..< Int(numberOfItemsPerRow) {
                    let identifier = items[row*3+col]
                    let storeItem = nodeLayer.childNode(withName: "Ball\(identifier)") as! StoreItem
                    if "Ball\(identifier)" == nextSelectedBall.identifier {
                        self.setFrameToThisItem(target: storeItem)
                    }
                }
            }
        }
    }
    
    func setFrameToThisItem(target: StoreItem) {
        target.setFrameToThisItem()
        frameNode.color = ColorCategory.InitialBallColor
        frameNode.position = target.position
    }
    
    func removeAllStoreItemActions() {
        for child in nodeLayer.children {
            if let storeItem = child as? StoreItem {
                storeItem.ballNode.setScale(1.0)
                storeItem.ballNode.removeAllActions()
            }
        }
    }
    
    func performAdsAddCoins() {
        self.coinNumber = coinNumber+15
        coinNumberNode.setScore(to: "\(coinNumber+15)")
        
        // play sound
        if gameSoundOn {
            self.run(addCoinsSound)
        }
    }
    
    func enableWatchVideo() {
        isAdReady = true
        
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
        watchVideoNode.run(fadeIn)
        
    }
    
    func disableWatchVideo() {
        //print(disableWatchVideo)
        isAdReady = false
        
        let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: 0.2)
        watchVideoNode.run(fadeOut)
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
        coinNumberNode.setScore(to: "\(coinNumber)")
        
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

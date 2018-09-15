//
//  GameScene.swift
//  OrbitMerge
//
//  Created by Alan Lou on 8/26/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import SpriteKit
import GameKit
import Photos
import Firebase

class GameScene: SKScene, Alertable, MenuButtonDelegate, ControlButtonDelegate {
    
    // super node containing the gamelayer and pauselayer
    private let gameLayer = SKNode()
    private let pauseLayer = SKNode()
    private let saveMeLayer = SKNode()
    private let gameOverLayer = SKNode()
    private let centerNode = SKNode()
    
    // array
    private var ballArray: [BallNode] = []
    private var mergeBallNumArray: [Int] = []
    
    // nodes
    private var circleNode: ZLSpriteNode
    private var circleAreaNode: ZLSpriteNode
    private var ballShadowNode: ZLSpriteNode
    private var arrowHeadNode: ZLSpriteNode
    private var arrowDotsNode: ZLSpriteNode
    private var topBarNode: TopBarNode
    private var newBestRibbon: NewBestRibbonNode?
    private let comboNode = ComboNode()
    
    // variables
    private var postImage: UIImage?
    private var safeAreaRect: CGRect!
    private var bottomSafeSets: CGFloat!
    private var currBallNode: BallNode?
    private var nextBallNode: BallNode?
    private var initialTouchPos: CGPoint?
    private var lastComboTime: TimeInterval = 0
    
    // booleans
    private var isGameStart: Bool = false
    private var isGameOver: Bool = false
    private var isBestScore: Bool = false
    private var isGamePaused: Bool = false
    private var isPhotoPermission: Bool = false
    private var isTappedEndSaveMe: Bool = false
    var isSaveMeAnOption: Bool = true
    var isAdReady: Bool = false
    var isFirstTimeOpening: Bool = false
    
    // numbers
    private var gameScore: Int = 0
    private var combo: Int = 1
    private var comboInc: Int = 0
    private var currMaxIndex: Int = 1
    private var mergeBallCount: Int = 0
    private let circleRadius: CGFloat
    private let ballWidth: CGFloat
    private let gameOverAngleDist: CGFloat
    private let countDownTime: TimeInterval = 8
    
    // message nodes
    private let scoreNode: MessageNode = MessageNode(message: "0", fontName: FontNameType.Montserrat_SemiBold)
    private let bestScoreNode: MessageNode = MessageNode(message: "0", fontName: FontNameType.Montserrat_SemiBold)
    
    // pre-load sound
    private let buttonPressedSound: SKAction = SKAction.playSoundFileNamed("buttonPressed.wav", waitForCompletion: false)
    private let gameOverSound: SKAction = SKAction.playSoundFileNamed("gameOver.wav", waitForCompletion: false)
    
    
    // IAP Product
    private var products = [SKProduct]()
    
    // stored values
    let levelTimerLabel = MessageNode(message: "5", fontName: FontNameType.Montserrat_Regular)
    var levelTimerValue: Int = 5 {
        didSet {
            levelTimerLabel.setText(to: "\(levelTimerValue)")
            if gameSoundOn {
                self.run(buttonPressedSound)
            }
        }
    }
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
    private var gameMusicOn: Bool {
        get {
            if  UserDefaults.standard.object(forKey: "gameMusicOn") == nil {
                UserDefaults.standard.set(true, forKey: "gameMusicOn")
            }
            return UserDefaults.standard.bool(forKey: "gameMusicOn")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "gameMusicOn")
        }
    }
    private var bestScore: Int {
        get {
            return UserDefaults.standard.integer(forKey: "highScore")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "highScore")
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
        circleRadius =  min(size.width, size.height*9.0/16.0)*0.5*0.85
        ballWidth = circleRadius * 0.190
        gameOverAngleDist = atan(ballWidth/circleRadius)
        
        // define nodes
        circleNode = ZLSpriteNode(width: circleRadius*2.0, image: "Circle", color: ColorCategory.InitialBallColor.withAlphaComponent(0.5))
        circleAreaNode = ZLSpriteNode(width: circleRadius*2.0, image: "CircleArea", color: ColorCategory.BallColor1.withAlphaComponent(0.5))
        arrowHeadNode = ZLSpriteNode(height: ballWidth*0.4, image: "ArrowHead", color: ColorCategory.InitialBallColor.withAlphaComponent(0.5))
        arrowDotsNode = ZLSpriteNode(height: ballWidth*0.2, image: "ArrowDots", color: ColorCategory.InitialBallColor.withAlphaComponent(0.5))
        ballShadowNode = ZLSpriteNode(width: ballWidth*1.2, image: "Ball", color: ColorCategory.BallColor1)
        topBarNode = TopBarNode(color: ColorCategory.getTopBarColor().withAlphaComponent(0.4), width: size.width, height: ballWidth*1.7)
        
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
        
        /*** set up game layer ***/
        gameLayer.position = CGPoint(x: 0.0, y: bottomSafeSets)
        self.addChild(gameLayer)
        gameLayer.name = "gamelayer"
        
        /*** set up pause layer ***/
        setUpPauseLayer()
        
        /*** set up pause button node ***/
        let pauseButtonNode = ControlButtonNode(color: ColorCategory.getControlButtonColor(), width: ballWidth*0.9, controlButtonType: ControlButtonType.PauseButton)
        pauseButtonNode.buttonDelegate = self
        pauseButtonNode.anchorPoint = CGPoint(x:0.0, y:1.0)
        pauseButtonNode.position = CGPoint(x:0, y:safeAreaRect.height)
        pauseButtonNode.alpha = 1.0
        pauseButtonNode.name = "pauseButtonNode"
        gameLayer.addChild(pauseButtonNode)
        
        /*** set up top bar node ***/
        topBarNode.position = CGPoint(x:safeAreaRect.width*0.5, y: safeAreaRect.height-pauseButtonNode.size.height*1.5/2.0)
        topBarNode.anchorPoint = CGPoint(x:0.5, y:1.0)
        gameLayer.addChild(topBarNode)
        
        setUpTopBarNode()
        
        /*** set up center node ***/
        centerNode.position = CGPoint(x: safeAreaRect.width*0.5, y: (adsHeight+topBarNode.frame.minY)*0.5)
        gameLayer.addChild(centerNode)
        arrowHeadNode.alpha = 0.0
        arrowHeadNode.anchorPoint = CGPoint(x:0.0, y:0.5)
        arrowHeadNode.position = CGPoint.zero
        centerNode.addChild(arrowHeadNode)
        
        arrowDotsNode.anchorPoint = CGPoint(x:0.0, y:0.5)
        arrowDotsNode.position = CGPoint(x: arrowHeadNode.size.width, y: 0.0)
        arrowHeadNode.addChild(arrowDotsNode)
        
        /*** set up circle node ***/
        circleNode.position = CGPoint.zero
        circleNode.zPosition = 1
        centerNode.addChild(circleNode)
        
        /*** set up circle area node ***/
        circleAreaNode.position = CGPoint.zero
        circleAreaNode.zPosition = 0
        circleAreaNode.alpha = 0.3
        circleAreaNode.setScale(0.0)
        centerNode.addChild(circleAreaNode)
            
        /*** set up ball shadow node ***/
        ballShadowNode.alpha = 0.0
        ballShadowNode.setScale(0.0)
        centerNode.addChild(ballShadowNode)
        
        /*** spawn init ball ***/
        spawnInitBall()
        
    }
    
    // MARK:- Touch Events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // get initial touch position
        let touch = touches.first
        let touchPosition = touch!.location(in: self)
        
        if self.currBallNode != nil && !isGameOver {
            initialTouchPos = touchPosition
        }
        
        // save me
        if isGameOver && isTappedEndSaveMe {
            let touchedNode = self.atPoint(touchPosition)
            print("TOUCH SAVE TOUCH SAVE!")
            if let name = touchedNode.name {
                // Game Over
                if name != "circle" && name != "saveMeComponent" {
                    gameOver()
                } else {
                    print("HEYHEYHEY! ONE MORE LIFE!")
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "runRewardAds"), object: nil)
                    disableAdsSaveMe()
                    // stop count down
                    centerNode.removeAllActions()
                }
                isTappedEndSaveMe = false
            } else {
                gameOver()
                isTappedEndSaveMe = false
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let initialTouchPos = self.initialTouchPos else {
            return
        }
        
        // get touch position
        let touch = touches.first
        let touchPosition = touch!.location(in: self)
        
        // calculate shooting angle
        let dy = initialTouchPos.y - touchPosition.y
        let dx = initialTouchPos.x - touchPosition.x
        
        // deal with different cases
        var shootingAngle: CGFloat = 0.0
        // case 1. touch not moving
        let touchDist = distBetweenTwoPoints(initialTouchPos, touchPosition)
        if touchDist < ballWidth {
            arrowHeadNode.alpha = 0.0
            return
        }
        
        if dx == 0 {
            // case 2. 90,270 degree
            shootingAngle = dy > 0 ? CGFloat.pi*1.5 : CGFloat.pi*0.5
        } else if dy == 0 {
            // case 3. 0,180 degree
            shootingAngle = dx > 0 ? 0.0 : CGFloat.pi
        } else if dx > 0 {
            // case 4. 90 to 270
            shootingAngle = 2.0*CGFloat.pi-atan(dy/dx)
        } else {
            // case 5. -90 to 90 degree
            shootingAngle = CGFloat.pi-atan(dy/dx)
        }
        
        arrowHeadNode.alpha = 1.0
        arrowHeadNode.zRotation = -shootingAngle
        
        // set scale of dots
        arrowDotsNode.setScale(min(sqrt((touchDist)/circleRadius),1.0))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let initialTouchPos = self.initialTouchPos else {
            return
        }
        
        // reset initial touch position
        self.initialTouchPos = nil
        
        // get touch position
        let touch = touches.first
        let touchPosition = touch!.location(in: self)
        
        // calculate shooting angle
        let dy = initialTouchPos.y - touchPosition.y
        let dx = initialTouchPos.x - touchPosition.x
        
        // deal with different cases
        var shootingAngle: CGFloat = 0.0
        // case 1. touch not moving
        if distBetweenTwoPoints(initialTouchPos,touchPosition) < ballWidth {
            arrowHeadNode.alpha = 0.0
            return
        }
        
        if dx == 0 {
            // case 2. 90,270 degree
            shootingAngle = dy > 0 ? CGFloat.pi*1.5 : CGFloat.pi*0.5
        } else if dy == 0 {
            // case 3. 0,180 degree
            shootingAngle = dx > 0 ? 0.0 : CGFloat.pi
        } else if dx > 0 {
            // case 4. 90 to 270 degree
            shootingAngle = 2.0*CGFloat.pi-atan(dy/dx)
        } else {
            // case 5. -90 to 90 degree
            shootingAngle = CGFloat.pi-atan(dy/dx)
        }
        
        arrowHeadNode.alpha = 1.0
        arrowHeadNode.zRotation = -shootingAngle

        
        let adjShootingAngle = CGFloat.pi*2.0-shootingAngle
        
        // shoot the ball
        shootBall(shootingAngle: adjShootingAngle)
        
        // fade out arrow node
        arrowHeadNode.alpha = 0.0
    }
    
    // MARK:- Game Logic
    func spawnInitBall() {
        // define ball on circle
        let initBallNode = BallNode(width: ballWidth, index: 1)
        
        initBallNode.setRotationAngle(to: 0.0)
        ballArray.insert(initBallNode, at: 0)
        initBallNode.zPosition = 10
        initBallNode.position = CGPoint(x: circleRadius, y: 0.0)
        centerNode.addChild(initBallNode)
        
        // define center ball node
        let centerBallNode = BallNode(width: ballWidth, index: 1)
        centerBallNode.zPosition = 10
        centerBallNode.position = CGPoint.zero
        centerBallNode.setScale(0.0)
        centerBallNode.alpha = 1.0
        centerNode.addChild(centerBallNode)
        
        self.currBallNode = centerBallNode
        
        mergeBallNumArray.insert(0, at: 0)
        
        // move center ball to position
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.15)
        let scaleDown = SKAction.scale(to: 0.85, duration: 0.05)
        let scaleBack = SKAction.scale(to: 1.0, duration: 0.05)
        
        centerBallNode.run(SKAction.sequence([scaleUp,scaleDown,scaleBack]))
        expandCircleArea(color: centerBallNode.getColor())
        
        // define upper left ball node
        let upperLeftBallNode = BallNode(width: ballWidth*0.75, index: 1)
        upperLeftBallNode.zPosition = 10
        upperLeftBallNode.position = CGPoint(x: -safeAreaRect.width*CGFloat(0.5)+CGFloat(7.0)+ballWidth*CGFloat(0.375),
                                             y: -topBarNode.size.height*CGFloat(1.15)-CGFloat(10.0)-ballWidth*CGFloat(0.375))
        upperLeftBallNode.setScale(0.0)
        upperLeftBallNode.alpha = 1.0
        topBarNode.addChild(upperLeftBallNode)
        self.nextBallNode = upperLeftBallNode
        
        upperLeftBallNode.run(SKAction.sequence([scaleUp,scaleDown,scaleBack]))
        
        self.isGameStart = true
    }
    
    func shootBall(shootingAngle: CGFloat) {
        
        if isGameOver {
            return
        }
        
        // ball not in position yet
        guard let currBallNode = self.currBallNode else {
            return
        }
        self.currBallNode = nil
        
        // define numbers
        let circleRadius = self.circleRadius
        
        // stop circle area expanding
        circleAreaNode.alpha = 0.0
        circleAreaNode.removeAllActions()
        
        // move current ball
        let moveBallToCircle = SKAction.move(to: CGPoint(x: circleRadius*cos(shootingAngle),
                                                         y: circleRadius*sin(shootingAngle)), duration: 0.2)
        let scaleUp = SKAction.scale(to: 1.3, duration: 0.15)
        let scaleDown = SKAction.scale(to: 0.6, duration: 0.1)
        let scaleBack = SKAction.scale(to: 1.0, duration: 0.08)
        currBallNode.run(SKAction.group([moveBallToCircle,scaleUp]), completion: {[weak self] in
            currBallNode.setRotationAngle(to: shootingAngle)
            self?.updateBallsArray(newBallNode: currBallNode)
            currBallNode.run(SKAction.sequence([scaleDown,scaleBack]))
        })
        
        // pause top bar combo countdown node
        pauseComboCountdown()
        
    }
    
    
    func spawnNewBall() {
        
        if isGameOver {
            return
        }
        
        guard let nextBallNode = self.nextBallNode else {
            return
        }
        
        // define random unit
        let randomUnit = Double(arc4random()) / Double(UInt32.max)
        
        // select ballIndex
        var ballIndex = 1
        var maxProb = 0.0
        for i in 1...currMaxIndex {
            maxProb = maxProb+exp(Double(i))
        }
        var cumuProb = 0.0
        for i in 1...currMaxIndex {
            cumuProb = cumuProb+exp(Double(currMaxIndex-i+1))
            if randomUnit > cumuProb/maxProb+0.01 {
                ballIndex = i+1
            }
        }
        
        // define center ball node
        let centerBallNode = BallNode(width: ballWidth, index: nextBallNode.getIndex())
        centerBallNode.zPosition = 10
        centerBallNode.position = CGPoint.zero
        centerBallNode.setScale(0.0)
        centerBallNode.alpha = 1.0
        centerNode.addChild(centerBallNode)
        
        self.currBallNode = centerBallNode
        
        // define upper left ball node
        let upperLeftBallNode = BallNode(width: ballWidth*0.75, index: ballIndex)
        upperLeftBallNode.zPosition = 10
        upperLeftBallNode.position = CGPoint(x: -safeAreaRect.width*CGFloat(0.5)+CGFloat(7.0)+ballWidth*CGFloat(0.375),
                                             y: -topBarNode.size.height*CGFloat(1.15)-CGFloat(10.0)-ballWidth*CGFloat(0.375))
        upperLeftBallNode.alpha = 1.0
        topBarNode.addChild(upperLeftBallNode)
        
        nextBallNode.removeFromParent()
        self.nextBallNode = upperLeftBallNode
        
        
        // move center ball to position
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
        let scaleDown = SKAction.scale(to: 0.85, duration: 0.05)
        let scaleBack = SKAction.scale(to: 1.0, duration: 0.05)
        
        centerBallNode.run(SKAction.sequence([scaleUp,scaleDown,scaleBack]))
        expandCircleArea(color: centerBallNode.getColor())
        
        
    }
        
    func updateBallsArray(newBallNode: BallNode) {
        
        if isGameOver {
            return
        }
        
        // define newRotationAngle
        let newRotationAngle = newBallNode.getRotationAngle()
        
        var rotationAngleBefore: CGFloat  = -10.0
        var rotationAngleAfter: CGFloat = -10.0
        
        if ballArray.count == 0 {
            // case 1. if the circle is empty, just insert it
            ballArray.insert(newBallNode, at: 0)
        } else if newRotationAngle < ballArray[0].getRotationAngle() {
            // case 2. insert at beginning
            rotationAngleAfter = ballArray[0].getRotationAngle()
            // insert ball
            ballArray.insert(newBallNode, at: 0)
        } else if newRotationAngle >= ballArray[ballArray.count-1].getRotationAngle() {
            // case 3. insert at end
            rotationAngleBefore = ballArray[ballArray.count-1].getRotationAngle()
            // insert ball
            ballArray.insert(newBallNode, at: ballArray.count)
        } else {
            for iterCount in 0..<ballArray.count-1 {
                if newRotationAngle >= ballArray[iterCount].getRotationAngle(),
                    newRotationAngle < ballArray[iterCount+1].getRotationAngle() {
                    // case 4. insert at middle
                    rotationAngleBefore = ballArray[iterCount].getRotationAngle()
                    rotationAngleAfter = ballArray[iterCount+1].getRotationAngle()
                    // insert ball
                    ballArray.insert(newBallNode, at: iterCount+1)
                    break
                }
            }
        }
        
        let distanceBefore = min(abs(rotationAngleBefore-newRotationAngle),abs(rotationAngleBefore-newRotationAngle-2.0*CGFloat.pi),abs(rotationAngleBefore-newRotationAngle+2.0*CGFloat.pi))
        let distanceAfter = abs(rotationAngleAfter-newRotationAngle)
        
        // check game over
        if min(distanceBefore,distanceAfter) < gameOverAngleDist {
            
            // animate
            let scaleDown = SKAction.scale(to: 0.5, duration: 0.2)
            let scaleUp = SKAction.scale(to: 0.73, duration: 0.2)
            let scaleBack = SKAction.scale(to: 0.6, duration: 0.1)
            scaleDown.timingMode = .easeOut
            let firstAction = SKAction.sequence([scaleDown,scaleUp,scaleBack])
            
            centerNode.run(firstAction, completion: {[weak self] in
                self?.promptAdSaveMe()
            })
            
            // game over
            return
        }
        //self.debugPrintBallArray(ballArray: self.ballArray)
        
        // check if spawn new ball
        let isMatched = checkBallsArray()
        
        if !isMatched {
            spawnNewBall()
        }
        
    }
    
    func checkBallsArray() -> Bool {
        
        if isGameOver {
            return false
        }
        
        // Case 1. Merge 3 balls
        if ballArray.count >= 3 {
            for iterCount in 0..<ballArray.count {
                // define ball nodes
                var ballNode1: BallNode!
                var ballNode2: BallNode!
                var ballNode3: BallNode!
                var ballNodeIndex1: Int!
                var ballNodeIndex2: Int!
                var ballNodeIndex3: Int!
                
                // n-3, n-2, n-1
                if iterCount < ballArray.count-2 {
                    ballNode1 = ballArray[iterCount]
                    ballNode2 = ballArray[iterCount+1]
                    ballNode3 = ballArray[iterCount+2]
                    ballNodeIndex1 = iterCount
                    ballNodeIndex2 = iterCount+1
                    ballNodeIndex3 = iterCount+2
                }
                // n-2, n-1, 0
                if iterCount == ballArray.count-2 {
                    ballNode1 = ballArray[iterCount]
                    ballNode2 = ballArray[iterCount+1]
                    ballNode3 = ballArray[0]
                    ballNodeIndex1 = iterCount
                    ballNodeIndex2 = iterCount+1
                    ballNodeIndex3 = 0
                }
                // n-1, 0, 1
                if iterCount == ballArray.count-1 {
                    ballNode1 = ballArray[iterCount]
                    ballNode2 = ballArray[0]
                    ballNode3 = ballArray[1]
                    ballNodeIndex1 = iterCount
                    ballNodeIndex2 = 0
                    ballNodeIndex3 = 1
                }
                
                if ballNode1.getIndex() == ballNode2.getIndex(),
                    ballNode2.getIndex() == ballNode3.getIndex() {
                    //self.debugPrintBallArray(ballArray: self.ballArray)
                    
                    /*** Found a 3-ball matching. Merge them! ***/
                    // calculate score
                    let scoreGot = ballNode1.getScore()+ballNode2.getScore()+ballNode3.getScore()
                    
                    // set new center nodes
                    let centerNode1 = SKNode()
                    let centerNode2 = SKNode()
                    let centerNode3 = SKNode()
                    centerNode1.position = CGPoint.zero
                    centerNode2.position = CGPoint.zero
                    centerNode3.position = CGPoint.zero
                    centerNode.addChild(centerNode1)
                    centerNode.addChild(centerNode2)
                    centerNode.addChild(centerNode3)
                    
                    // move balls to new center nodes
                    ballNode1.removeFromParent()
                    centerNode1.addChild(ballNode1)
                    ballNode2.removeFromParent()
                    centerNode2.addChild(ballNode2)
                    ballNode3.removeFromParent()
                    centerNode3.addChild(ballNode3)
                    
                    // calculate target rotation angles
                    let targetRotationAngle1 = (ballNode1.getRotationAngle()+ballNode2.getRotationAngle()+ballNode3.getRotationAngle())/3.0
                    let targetRotationAngle2 = targetRotationAngle1+CGFloat.pi*(2.0/3.0)
                    let targetRotationAngle3 = targetRotationAngle1-CGFloat.pi*(2.0/3.0)
                    
                    // calculate rotation distance for all rotation angles
                    var rotateDist1 = distBetweenTwoAngles(ballNode1.getRotationAngle(),targetRotationAngle1) + distBetweenTwoAngles(ballNode2.getRotationAngle(),targetRotationAngle1) + distBetweenTwoAngles(ballNode3.getRotationAngle(),targetRotationAngle1)
                    var rotateDist2 = distBetweenTwoAngles(ballNode1.getRotationAngle(),targetRotationAngle2) + distBetweenTwoAngles(ballNode2.getRotationAngle(),targetRotationAngle2) + distBetweenTwoAngles(ballNode3.getRotationAngle(),targetRotationAngle2)
                    var rotateDist3 = distBetweenTwoAngles(ballNode1.getRotationAngle(),targetRotationAngle3) + distBetweenTwoAngles(ballNode2.getRotationAngle(),targetRotationAngle3) + distBetweenTwoAngles(ballNode3.getRotationAngle(),targetRotationAngle3)
                    
                    // if it's running across other nodes, don't use this target position
                    let (isRunningAcross1,tempAngleArray1) = self.isRunningAcrossOtherNodes3(newAngle: targetRotationAngle1, forIndex: ballNode1.getIndex(), removeArrayIndex: [ballNodeIndex1,ballNodeIndex2,ballNodeIndex3], angleAdj: 0.0)
                    let (isRunningAcross2,tempAngleArray2) = self.isRunningAcrossOtherNodes3(newAngle: targetRotationAngle2, forIndex: ballNode1.getIndex(), removeArrayIndex: [ballNodeIndex1,ballNodeIndex2,ballNodeIndex3], angleAdj: CGFloat.pi*2.0)
                    let (isRunningAcross3,tempAngleArray3) = self.isRunningAcrossOtherNodes3(newAngle: targetRotationAngle3, forIndex: ballNode1.getIndex(), removeArrayIndex: [ballNodeIndex1,ballNodeIndex2,ballNodeIndex3], angleAdj: -CGFloat.pi*2.0)
                    
                    if isRunningAcross1 {
                        rotateDist1 = 10000.0
                    }
                    if isRunningAcross2 {
                        rotateDist2 = 10000.0
                    }
                    if isRunningAcross3 {
                        rotateDist3 = 10000.0
                    }
                    
                    // determine which target rotation angle to use
                    var targetRotationAngle: CGFloat = targetRotationAngle1
                    var targetRotateDist: CGFloat = rotateDist1
                    var tempAngleArray: [CGFloat] = tempAngleArray1
                        
                    if rotateDist2 <= rotateDist1, rotateDist2 <= rotateDist3 {
                        targetRotationAngle = targetRotationAngle2
                        targetRotateDist = rotateDist2
                        tempAngleArray = tempAngleArray2
                    } else if rotateDist3 <= rotateDist1, rotateDist3 <= rotateDist2 {
                        targetRotationAngle = targetRotationAngle3
                        targetRotateDist = rotateDist3
                        tempAngleArray = tempAngleArray3
                    }
                    
                    // calculate angles to rotate
                    var rotateAngle1 = ballNode1.getRotationAngle()-targetRotationAngle
                    var rotateAngle2 = ballNode2.getRotationAngle()-targetRotationAngle
                    var rotateAngle3 = ballNode3.getRotationAngle()-targetRotationAngle
                    
                    rotateAngle1 = tempAngleArray[0]-targetRotationAngle
                    rotateAngle2 = tempAngleArray[1]-targetRotationAngle
                    rotateAngle3 = tempAngleArray[2]-targetRotationAngle

                    // animate rotation
                    let rotateAction1 = SKAction.rotate(byAngle: -rotateAngle1, duration: max(TimeInterval(sqrt(targetRotateDist)*0.13),0.13))
                    let rotateAction2 = SKAction.rotate(byAngle: -rotateAngle2, duration: max(TimeInterval(sqrt(targetRotateDist)*0.13),0.13))
                    let rotateAction3 = SKAction.rotate(byAngle: -rotateAngle3, duration: max(TimeInterval(sqrt(targetRotateDist)*0.13),0.13))
                    
                    // remove all the balls and merge them together
                    centerNode1.run(rotateAction1, completion: {
                        centerNode1.removeFromParent()
                    })
                    centerNode2.run(rotateAction2, completion: {
                        centerNode2.removeFromParent()
                    })
                    centerNode3.run(rotateAction3, completion: {
                        centerNode3.removeFromParent()
                    })
                    
                    self.ballArray.remove(at: [ballNodeIndex1,ballNodeIndex2,ballNodeIndex3])
                    
                    // add the merged ball
                    let wait = SKAction.wait(forDuration: 0.2)
                    let mergedBall = BallNode(width: ballWidth, index: ballNode1.getIndex()+1)
                    mergedBall.zPosition = 10
                    
                    // move mergedBall onto center node
                    mergedBall.position = CGPoint(x: circleRadius*cos(targetRotationAngle),
                                                  y: circleRadius*sin(targetRotationAngle))
                    mergedBall.setRotationAngle(to: targetRotationAngle)
                    mergedBall.alpha = 0.0
                    self.centerNode.addChild(mergedBall)
                    
                    // run animation to add in merged ball
                    let fadeIn = SKAction.fadeIn(withDuration: 0.12)
                    let scaleUp1 = SKAction.scale(to: 1.8, duration: 0.12)
                    let scaleDown1 = SKAction.scale(to: 0.6, duration: 0.12)
                    let scaleUp2 = SKAction.scale(to: 1.2, duration: 0.06)
                    let scaleDown2 = SKAction.scale(to: 0.9, duration: 0.06)
                    let scaleBack = SKAction.scale(to: 1.0, duration: 0.06)
                    mergedBall.run(wait, completion: {[weak self] in
                        self?.mergeNewBallEffect(ballNode: mergedBall)
                        // update score
                        self?.incrementScore(by: scoreGot, from: mergedBall)
                        mergedBall.run(SKAction.sequence([SKAction.group([fadeIn,scaleUp1]),scaleDown1,scaleUp2,scaleDown2,scaleBack]), completion: {[weak self] in
                            self?.updateBallsArray(newBallNode: mergedBall)
                        })
                    })
                    
                    // already found a 3-ball matching, no need to check for 2 merge
                    return true
                }
            }
            
        }
        
        
        if ballArray.count >= 2 {
            // Case 2. Merge 2 balls
            for iterCount in 0..<ballArray.count {
                // define ball nodes
                var ballNode1: BallNode!
                var ballNode2: BallNode!
                var ballNodeIndex1: Int!
                var ballNodeIndex2: Int!
                
                // n-2, n-1
                if iterCount < ballArray.count-1 {
                    ballNode1 = ballArray[iterCount]
                    ballNode2 = ballArray[iterCount+1]
                    ballNodeIndex1 = iterCount
                    ballNodeIndex2 = iterCount+1
                }
                // n-1, 0
                if iterCount == ballArray.count-1 {
                    ballNode1 = ballArray[iterCount]
                    ballNode2 = ballArray[0]
                    ballNodeIndex1 = iterCount
                    ballNodeIndex2 = 0
                }
                
                if ballNode1.getIndex() == ballNode2.getIndex() {
                    //self.debugPrintBallArray(ballArray: self.ballArray)
                    
                    /*** Found a 2-ball matching. Merge them! ***/
                    // calculate score
                    let scoreGot = ballNode1.getScore()+ballNode2.getScore()
                    
                    // set new center nodes
                    let centerNode1 = SKNode()
                    let centerNode2 = SKNode()
                    centerNode1.position = CGPoint.zero
                    centerNode2.position = CGPoint.zero
                    centerNode.addChild(centerNode1)
                    centerNode.addChild(centerNode2)
                    
                    // move balls to new center nodes
                    ballNode1.removeFromParent()
                    centerNode1.addChild(ballNode1)
                    ballNode2.removeFromParent()
                    centerNode2.addChild(ballNode2)
                    
                    // calculate target rotation angles
                    let targetRotationAngle1 = (ballNode1.getRotationAngle()+ballNode2.getRotationAngle())/2.0
                    let targetRotationAngle2 = targetRotationAngle1+CGFloat.pi
                    let targetRotationAngle3 = targetRotationAngle1-CGFloat.pi
                    
                    // calculate rotation distance for all rotation angles
                    var rotateDist1 = distBetweenTwoAngles(ballNode1.getRotationAngle(),targetRotationAngle1) + distBetweenTwoAngles(ballNode2.getRotationAngle(),targetRotationAngle1)
                    var rotateDist2 = distBetweenTwoAngles(ballNode1.getRotationAngle(),targetRotationAngle2) + distBetweenTwoAngles(ballNode2.getRotationAngle(),targetRotationAngle2)
                    var rotateDist3 = distBetweenTwoAngles(ballNode1.getRotationAngle(),targetRotationAngle3) + distBetweenTwoAngles(ballNode2.getRotationAngle(),targetRotationAngle3)
                    
                    // if it's running across other nodes, don't use this target position
                    let (isRunningAcross1,tempAngleArray1) = self.isRunningAcrossOtherNodes2(newAngle: targetRotationAngle1, forIndex: ballNode1.getIndex(), removeArrayIndex: [ballNodeIndex1,ballNodeIndex2], angleAdj: 0.0)
                    let (isRunningAcross2,tempAngleArray2) = self.isRunningAcrossOtherNodes2(newAngle: targetRotationAngle2, forIndex: ballNode1.getIndex(), removeArrayIndex: [ballNodeIndex1,ballNodeIndex2], angleAdj: CGFloat.pi*2.0)
                    let (isRunningAcross3,tempAngleArray3) = self.isRunningAcrossOtherNodes2(newAngle: targetRotationAngle3, forIndex: ballNode1.getIndex(), removeArrayIndex: [ballNodeIndex1,ballNodeIndex2], angleAdj: -CGFloat.pi*2.0)
                    
                    if isRunningAcross1 {
                        rotateDist1 = 10000.0
                    }
                    if isRunningAcross2 {
                        rotateDist2 = 10000.0
                    }
                    if isRunningAcross3 {
                        rotateDist3 = 10000.0
                    }
                    
                    // determine which target rotation angle to use
                    var targetRotationAngle: CGFloat = targetRotationAngle1
                    var targetRotateDist: CGFloat = rotateDist1
                    var tempAngleArray: [CGFloat] = tempAngleArray1
                    
                    if rotateDist2 <= rotateDist1, rotateDist2 <= rotateDist3 {
                        targetRotationAngle = targetRotationAngle2
                        targetRotateDist = rotateDist2
                        tempAngleArray = tempAngleArray2
                    } else if rotateDist3 <= rotateDist1, rotateDist3 <= rotateDist2 {
                        targetRotationAngle = targetRotationAngle3
                        targetRotateDist = rotateDist3
                        tempAngleArray = tempAngleArray3
                    }
                    
                    // calculate angles to rotate
                    var rotateAngle1 = ballNode1.getRotationAngle()-targetRotationAngle
                    var rotateAngle2 = ballNode2.getRotationAngle()-targetRotationAngle
                    
                    rotateAngle1 = tempAngleArray[0]-targetRotationAngle
                    rotateAngle2 = tempAngleArray[1]-targetRotationAngle
                    
                    // animate rotation
                    let rotateAction1 = SKAction.rotate(byAngle: -rotateAngle1, duration: max(TimeInterval(sqrt(targetRotateDist)*0.13),0.13))
                    let rotateAction2 = SKAction.rotate(byAngle: -rotateAngle2, duration: max(TimeInterval(sqrt(targetRotateDist)*0.13),0.13))
                   
                    // remove all the balls and merge them together
                    centerNode1.run(rotateAction1, completion: {
                        centerNode1.removeFromParent()
                    })
                    centerNode2.run(rotateAction2, completion: {
                        centerNode2.removeFromParent()
                    })
                    
                    self.ballArray.remove(at: [ballNodeIndex1,ballNodeIndex2])
                    
                    // add the merged ball
                    let wait = SKAction.wait(forDuration: 0.2)
                    let mergedBall = BallNode(width: ballWidth, index: ballNode1.getIndex()+1)
                    mergedBall.zPosition = 10
                    
                    // move mergedBall onto center node
                    mergedBall.position = CGPoint(x: circleRadius*cos(targetRotationAngle),
                                                  y: circleRadius*sin(targetRotationAngle))
                    mergedBall.setRotationAngle(to: targetRotationAngle)
                    mergedBall.alpha = 0.0
                    self.centerNode.addChild(mergedBall)
                    
                    // run animation to add in merged ball
                    let fadeIn = SKAction.fadeIn(withDuration: 0.12)
                    let scaleUp1 = SKAction.scale(to: 1.8, duration: 0.12)
                    let scaleDown1 = SKAction.scale(to: 0.6, duration: 0.12)
                    let scaleUp2 = SKAction.scale(to: 1.2, duration: 0.06)
                    let scaleDown2 = SKAction.scale(to: 0.9, duration: 0.06)
                    let scaleBack = SKAction.scale(to: 1.0, duration: 0.06)
                    mergedBall.run(wait, completion: {[weak self] in
                        self?.mergeNewBallEffect(ballNode: mergedBall)
                        // update score
                        self?.incrementScore(by: scoreGot, from: mergedBall)
                        mergedBall.run(SKAction.sequence([SKAction.group([fadeIn,scaleUp1]),scaleDown1,scaleUp2,scaleDown2,scaleBack]), completion: {[weak self] in
                            self?.updateBallsArray(newBallNode: mergedBall)
                        })
                    })
                    
                    // already found a 3-ball matching, break out of loop
                    return true
                }
            }
        }
        
        // did not find any matching
        return false
    }
    
    func incrementScore(by score: Int, from mergeBall: BallNode) {
        self.gameScore = self.gameScore+(score*self.combo)
        self.scoreNode.setScore(to: "\(self.gameScore)")
        
        
        let scoreUpMessageNodeWidth = ballWidth*1.8
        let scoreUpMessageNodeHeight = ballWidth*0.65
        let scoreUpMessageNodeFrame = CGRect(x: -scoreUpMessageNodeWidth*0.5,
                                                  y: ballWidth*0.5,
                                                  width: scoreUpMessageNodeWidth,
                                                  height: scoreUpMessageNodeHeight)
        let scoreUpMessageNode = MessageNode(message: "+\(score*self.combo) ", fontName: FontNameType.Montserrat_SemiBold)
        scoreUpMessageNode.zPosition = 100
        scoreUpMessageNode.setFontColor(color: mergeBall.getColor())
        scoreUpMessageNode.adjustLabelFontSizeToFitRect(rect: scoreUpMessageNodeFrame)
        scoreUpMessageNode.setHorizontalAlignment(mode: .center)
        scoreUpMessageNode.position = mergeBall.position
        scoreUpMessageNode.setScale(0.0)
        centerNode.addChild(scoreUpMessageNode)
        
        // define actions
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        let moveUp = SKAction.moveBy(x: 0.0, y: ballWidth*1.2, duration: 0.8)
        let scaleDown = SKAction.scale(to: 0.87, duration: 0.8)
        let fadeOut = SKAction.fadeOut(withDuration: 0.13)
        moveUp.timingMode = .easeOut
        
        scoreUpMessageNode.run(SKAction.sequence([scaleUp,SKAction.group([moveUp,scaleDown]),fadeOut]),completion:{
            scoreUpMessageNode.removeFromParent()
        })
        
        
        // check high score
        if gameScore > self.bestScore, !isBestScore {
            isBestScore = true
            
            newBestRibbon = NewBestRibbonNode(height: ballWidth*0.9)
            newBestRibbon!.position = CGPoint(x: safeAreaRect.width + newBestRibbon!.size.width/2,
                                              y: safeAreaRect.height-ballWidth*0.9*0.75)
            newBestRibbon!.zPosition = 200
            gameLayer.addChild(newBestRibbon!)
            
            // play sound
            let moveAction = SKAction.move(by: CGVector(dx: -newBestRibbon!.size.width, dy: 0), duration: 0.5)
            let wait = SKAction.wait(forDuration: 3.0)
            let moveBackAction = SKAction.move(by: CGVector(dx: newBestRibbon!.size.width, dy: 0), duration: 0.5)
            if gameSoundOn{
                let newBestScoreSound = SKAction.playSoundFileNamed(
                    "newBestScore.wav", waitForCompletion: false)
                newBestRibbon!.run(SKAction.sequence([SKAction.group([moveAction, newBestScoreSound]),wait, moveBackAction]))
            } else {
                newBestRibbon!.run(SKAction.sequence([moveAction, wait, moveBackAction]))
            }
        }
        
        // update best score label
        if isBestScore {
            bestScoreNode.setScore(to: "\(self.gameScore)")
        }
        
    }
    
    func setComboNumber(to comboNum: Int) {
        self.combo = comboNum
        self.comboNode.setCombo(to: comboNum)
    }
    
    func promptAdSaveMe() {
        
        // deactivate top bar
        for child in topBarNode.children {
            child.removeAllActions()
        }
        
        if !isGameOver {
            isGameOver = true
            if isAdReady, isSaveMeAnOption {
                self.askSaveMe()
            } else {
                self.gameOver()
            }
        }
        
    }
    
    // run before game over
    func askSaveMe() {
        print("askSaveMe")
        isSaveMeAnOption = false
        
        // add saveMeLayer
        saveMeLayer.position = gameLayer.position
        self.addChild(saveMeLayer)
        
        // set up tap message node
        let saveMeNode = MessageNode(message: "Save Me?", fontName: FontNameType.Montserrat_SemiBold)
        let saveMeNodeWidth = circleRadius*1.0
        let saveMeNodeHeight = circleRadius/1.5
        let saveMeNodeFrame = CGRect(x: -saveMeNodeWidth/2,
                                     y: circleRadius/5,
                                     width: saveMeNodeWidth,
                                     height: saveMeNodeHeight)
        saveMeNode.adjustLabelFontSizeToFitRect(rect: saveMeNodeFrame)
        saveMeNode.name = "saveMeComponent"
        //debugDrawArea(rect: messageNodeFrame)
        centerNode.addChild(saveMeNode)
        
        // set up levelTimerLabel
        let levelTimerLabelWidth = circleRadius*0.5
        let levelTimerLabelHeight = circleRadius*0.5
        let levelTimerLabelFrame = CGRect(x: -levelTimerLabelWidth*0.5,
                                          y: -levelTimerLabelHeight*0.5,
                                          width: levelTimerLabelWidth,
                                          height: levelTimerLabelHeight)
        levelTimerLabel.adjustLabelFontSizeToFitRect(rect: levelTimerLabelFrame)
        levelTimerLabel.name = "saveMeComponent"
        //debugDrawArea(rect: messageNodeFrame)
        centerNode.addChild(levelTimerLabel)
        
        // Ads Video
        let adsVideoNode = AdsVideoNode(color: ColorCategory.getMessageFontColor(), height: circleRadius*0.28)
        adsVideoNode.position = CGPoint(x:0.0, y:-circleRadius/5-circleRadius*0.32)
        adsVideoNode.name = "saveMeComponent"
        adsVideoNode.zPosition = 10000
        centerNode.addChild(adsVideoNode)
        //print(adsVideoNode)
        
        
        // animate
        let scaleDown = SKAction.scale(to: 0.5, duration: 0.2)
        let scaleUp = SKAction.scale(to: 0.73, duration: 0.2)
        let scaleBack = SKAction.scale(to: 0.6, duration: 0.1)
        scaleDown.timingMode = .easeOut
        
        let wait = SKAction.wait(forDuration: 1.0) //change countdown speed here
        let block = SKAction.run({[unowned self] in
            if self.levelTimerValue >= 0 {
                self.levelTimerValue = self.levelTimerValue-1
            }
        })
        let sequence = SKAction.sequence([wait,scaleUp,block,scaleBack])
        
        centerNode.run(SKAction.repeat(sequence, count: 5), completion: {[weak self] in
            self?.gameOver()
        })
        
        // set up tap to skip message node
        let tapToSkipNodeWidth = safeAreaRect.width*0.35
        let tapToSkipNodeHeight = ballWidth*2.0
        let tapToSkipNodeFrame = CGRect(x: safeAreaRect.width*CGFloat(0.5)-tapToSkipNodeWidth*CGFloat(0.5),
                                        y: safeAreaRect.size.height*CGFloat(0.25)-circleRadius*CGFloat(0.3)-tapToSkipNodeHeight*CGFloat(0.5),
                                        width: tapToSkipNodeWidth,
                                        height: tapToSkipNodeHeight)
        
        let tapToSkipTextNode: MessageNode = MessageNode(message: "TAP TO SKIP", fontName: FontNameType.Montserrat_Regular)
        tapToSkipTextNode.setFontColor(color: ColorCategory.getTextFontColor())
        tapToSkipTextNode.adjustLabelFontSizeToFitRect(rect: tapToSkipNodeFrame)
        tapToSkipTextNode.name = "taptoskiptextnode"
        gameLayer.addChild(tapToSkipTextNode)
        
        // animate tap to skip text node
        let waitBetween = SKAction.wait(forDuration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let fadeIn = SKAction.fadeIn(withDuration: 0.2)
        let actionSequence = SKAction.sequence([waitBetween,fadeOut,fadeIn])
        tapToSkipTextNode.run(SKAction.repeatForever(actionSequence))
        
        // last line
        isTappedEndSaveMe = true
    }
    
    func expandCircleArea(color: SKColor) {
        let circleOutDuration: TimeInterval = 3.0
        let circleAreaFadeAndExpand = SKAction.group([SKAction.fadeOut(withDuration: circleOutDuration),
                                                      SKAction.scale(to: 0.5, duration: circleOutDuration)])
        let circleAreaScaleBack = SKAction.scale(to: 0.0, duration: 0.5)
        let circleAreaFadeIn = SKAction.fadeAlpha(to: 0.25, duration: 0.1)
        let circleSequenceAction = SKAction.sequence([circleAreaFadeAndExpand,circleAreaScaleBack,circleAreaFadeIn])
        let wait = SKAction.wait(forDuration: 0.25)
        circleAreaFadeIn.timingMode = .easeOut
        circleAreaNode.color = color
        circleAreaNode.alpha = 0.25
        circleAreaNode.setScale(0.0)
        circleAreaNode.run(SKAction.sequence([wait,SKAction.repeatForever(circleSequenceAction)]))
    }
    
    func mergeNewBallEffect(ballNode: BallNode) {
        
        // add emitter
        let emitter = SKEmitterNode()
        let particleTexture = SKTexture(imageNamed: "Ball")
        emitter.particleSize = CGSize(width: ballWidth*0.37, height: ballWidth*0.37)
        emitter.particleTexture = particleTexture
        emitter.particleBirthRate = 150
        emitter.numParticlesToEmit = 25
        emitter.particleLifetime = 1.0
        emitter.emissionAngle = 0.0
        emitter.emissionAngleRange = CGFloat.pi*2
        emitter.particleSpeed = 80
        emitter.particleSpeedRange = 20
        emitter.particleAlpha = 0.6
        emitter.particleAlphaRange = 0.2
        emitter.particleAlphaSpeed = -0.7
        emitter.particleScale = 1.0
        emitter.particleScaleRange = 0.2
        emitter.particleScaleSpeed = -0.5
        emitter.particleColorBlendFactor = 1.0
        emitter.particleColor = ballNode.color
        emitter.particleColorBlendFactorSequence = nil
        emitter.particleBlendMode = SKBlendMode.alpha
        emitter.position = ballNode.position
        emitter.zPosition = 100
        centerNode.addChild(emitter)
        emitter.run(SKAction.sequence([SKAction.wait(forDuration: 1.0),
                                       SKAction.removeFromParent()]))
        
        // add shadow
        ballShadowNode.removeAllActions()
        ballShadowNode.changeColor(to: ballNode.color)
        ballShadowNode.zPosition = 0
        ballShadowNode.alpha = 0.3
        ballShadowNode.setScale(0.3)
        ballShadowNode.position = ballNode.position
        
        // animate ball shadow
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.3)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        scaleUp.timingMode = .easeOut
        fadeOut.timingMode = .easeIn
        ballShadowNode.run(SKAction.sequence([scaleUp,fadeOut]))
        
        // shake camera
        let shootAngle = ballNode.getRotationAngle()
        shakeCamera(layer: centerNode, direction: CGVector(dx: cos(shootAngle), dy: sin(shootAngle)), numberOfShakes: 1, magnitude: ballWidth*0.4)
        
        /*** check if it's a higher index ball ***/
        // update currMaxIndex
        if ballNode.getIndex() > currMaxIndex {
            currMaxIndex = ballNode.getIndex()
        }
        
        /*** check if it's combo ***/
        let currentComboTime = NSDate().timeIntervalSince1970
        if currentComboTime-lastComboTime < 1.0 {
            self.comboInc += 1
            continueComboCountdown()
        } else {
            self.comboInc = 0
        }
        
        // combo higher than previous one
        if comboInc > combo-1 {
            self.setComboNumber(to: comboInc+1)
            startComboCountdown(by: ballNode)
        }
        
        // update lastComboTime
        lastComboTime = currentComboTime
        
        // accumulate mergeBallCount
        mergeBallCount += 1
        
        // update mergeBallNumArray
        if ballNode.getIndex() > mergeBallNumArray.count {
            mergeBallNumArray.insert(1, at: mergeBallNumArray.count)
        } else {
            mergeBallNumArray[ballNode.getIndex()-1] += 1
        }
        print("YOYO")
        print(mergeBallNumArray)
    }
    
    func startComboCountdown(by ballNode: BallNode) {
        if let countDownNode = topBarNode.childNode(withName: "countDownNode") {
            countDownNode.removeAllActions()
            countDownNode.removeFromParent()
        }
        
        let countDownNode = SKSpriteNode(texture: nil, color: ColorCategory.getBallColor(index: ballNode.getIndex()-1), size: topBarNode.size)
        countDownNode.position = CGPoint.zero
        countDownNode.zPosition = 1
        countDownNode.anchorPoint = CGPoint(x:0.5, y:1.0)
        countDownNode.name = "countDownNode"
        topBarNode.addChild(countDownNode)
        
        // animate
        let countDownAction = SKAction.scaleX(to: 0.0, y: 1.0, duration: countDownTime)
        countDownNode.run(countDownAction, completion:{
            countDownNode.removeFromParent()
            self.combo = 0
            self.setComboNumber(to: 1)
        })
    }
    
    func continueComboCountdown() {
        
        guard let countDownNode = topBarNode.childNode(withName: "countDownNode") else {
            return
        }
        
        // animate
        countDownNode.removeAllActions()
        let scaleBack = SKAction.scaleX(to: 1.0, y: 1.0, duration: 0.3)
        let countDownAction = SKAction.scaleX(to: 0.0, y: 1.0, duration: countDownTime)
        countDownNode.run(SKAction.sequence([scaleBack,countDownAction]), completion:{
            countDownNode.removeFromParent()
            self.combo = 0
            self.setComboNumber(to: 1)
        })
    }
    
    func pauseComboCountdown() {
        
        guard let countDownNode = topBarNode.childNode(withName: "countDownNode") else {
            return
        }
        
        // animate
        let wait = SKAction.wait(forDuration: 0.2)
        countDownNode.isPaused = true
        self.run(wait, completion:{
            countDownNode.isPaused = false
        })
    }
    
    func shakeCamera(layer:SKNode, direction: CGVector, numberOfShakes:Int, magnitude: CGFloat) {
        let amplitudeX:CGFloat = 1.0 * magnitude;
        let amplitudeY:CGFloat = 1.0 * magnitude;
        let directionX = direction.dx/direction.dx.magnitude
        let directionY = direction.dy/direction.dy.magnitude
        var actionsArray:[SKAction] = [];
        for _ in 1...numberOfShakes {
            let moveX = directionX*amplitudeX - amplitudeX/2.0
            let moveY = directionY*amplitudeY - amplitudeY/2.0
            let shakeAction = SKAction.moveBy(x: CGFloat(moveX), y: CGFloat(moveY), duration: 0.03)
            shakeAction.timingMode = SKActionTimingMode.easeOut
            actionsArray.append(shakeAction)
            let shakeActionBack = SKAction.moveBy(x: CGFloat(-moveX), y: CGFloat(-moveY), duration: 0.05)
            actionsArray.append(shakeActionBack)
        }
        
        let actionSeq = SKAction.sequence(actionsArray)
        layer.run(actionSeq)
    }
    
    
    //MARK:- Game Over Logic
    func gameOver() {
        print("GAMEOVER!!!")
        
        if let tapToSkipNode = gameLayer.childNode(withName: "taptoskiptextnode") {
            tapToSkipNode.removeFromParent()
        }
        centerNode.removeAllActions()
        
        if gameSoundOn {
            self.run(gameOverSound)
        }
        
        isGameOver = true
        
        // update high score if current game score is higher
        if gameScore >= self.bestScore {
            self.bestScore = gameScore
            Analytics.logEvent("new_highscore", parameters: [
                "highscore": gameScore as NSInteger
                ])
            if let newBestRibbon = newBestRibbon {
                let moveBackAction = SKAction.move(by: CGVector(dx: newBestRibbon.size.width, dy: 0), duration: 0.5)
                newBestRibbon.run(moveBackAction)
            }
            // ask for review
            StoreReviewHelper.incrementAppHighScoreCount()
            StoreReviewHelper.checkAndAskForReview()
        }
        
        // animate balls exploding
        self.gameEndBallEffect()
        
    }
    
    func setUpGameOverLayer() {
        self.addChild(gameOverLayer)
        gameOverLayer.position = gameLayer.position
        gameOverLayer.alpha = 0.0
        
        // animate center node
        let scaleUp = SKAction.scale(by: 1.1, duration: 0.1)
        let scaleToZero = SKAction.scale(to: 0.0, duration: 0.2)
        scaleToZero.timingMode = .easeOut
        self.centerNode.run(SKAction.sequence([scaleUp,scaleToZero]))
        
        // slide back next node
        let slideRightALittle = SKAction.moveBy(x: ballWidth*0.3, y: 0.0, duration: 0.3)
        let slideBack = SKAction.moveBy(x: -safeAreaRect.width*0.3, y: 0.0, duration: 0.3)
        if let nextBallMessage = topBarNode.childNode(withName: "nextBallMessage") {
            nextBallMessage.run(SKAction.sequence([slideRightALittle,slideBack]))
        }
        if let nextBallNode = self.nextBallNode {
            nextBallNode.run(SKAction.sequence([slideRightALittle,slideBack]))
        }
        
        // set up top message node
        let topMessageNodeWidth = safeAreaRect.width*0.8
        let topMessageNodeHeight = ballWidth*0.7
        let topMessageNodeFrame = CGRect(x: safeAreaRect.width*0.5-topMessageNodeWidth*0.5,
                                              y: topBarNode.frame.minY*0.9-topMessageNodeHeight,
                                              width: topMessageNodeWidth,
                                              height: topMessageNodeHeight)
        let topMessage = MessageNode(message: "You merged \(mergeBallCount) Balls!", fontName: FontNameType.Montserrat_SemiBold)
        topMessage.zPosition = 100
        topMessage.setFontColor(color: ColorCategory.getTopBarColor())
        topMessage.adjustLabelFontSizeToFitRect(rect: topMessageNodeFrame)
        gameOverLayer.addChild(topMessage)
        
        
        /*** Bottom Section ***/
        // Restart Node
        let buttonHeight = ballWidth*1.3
        let restartButton = MenuButtonNode(color: ColorCategory.BallColor3,
                                           buttonType: ButtonType.LongTextButton,
                                           iconType: IconType.SmallRestartButton,
                                           height: buttonHeight,
                                           text: "RESTART")
        let buttonWidth = restartButton.size.width
        restartButton.zPosition = 100
        restartButton.position = CGPoint(x: safeAreaRect.width/2,
                                         y: buttonHeight*5.0)
        restartButton.name = "restartButton"
        restartButton.buttonDelegate = self
        gameOverLayer.addChild(restartButton)
        
        // add home button
        let homeButton = MenuButtonNode(color: ColorCategory.BallColor1,
                                        buttonType: ButtonType.RoundButton,
                                        iconType: IconType.HomeButton,
                                        height: buttonHeight)
        homeButton.zPosition = 100
        homeButton.position = CGPoint(x: safeAreaRect.width*0.5-buttonWidth*0.375,
                                      y: buttonHeight*3.0)
        homeButton.name = "homebutton"
        homeButton.buttonDelegate = self
        gameOverLayer.addChild(homeButton)
        
        // add share button
        let shareButton = MenuButtonNode(color: ColorCategory.BallColor2,
                                         buttonType: ButtonType.RoundButton,
                                         iconType: IconType.ShareButton,
                                         height: buttonHeight)
        shareButton.zPosition = 100
        shareButton.position = CGPoint(x: safeAreaRect.width*0.5,
                                       y: buttonHeight*3.0)
        shareButton.name = "sharebutton"
        shareButton.buttonDelegate = self
        gameOverLayer.addChild(shareButton)
        
        // add leaderboard button
        let leaderboardButton = MenuButtonNode(color: ColorCategory.BallColor4,
                                               buttonType: ButtonType.RoundButton,
                                               iconType: IconType.LeaderBoardButton,
                                               height: buttonHeight)
        leaderboardButton.zPosition = 100
        leaderboardButton.position = CGPoint(x: safeAreaRect.width*0.5+buttonWidth*0.375,
                                             y: buttonHeight*3.0)
        leaderboardButton.name = "leaderboardbutton"
        leaderboardButton.buttonDelegate = self
        gameOverLayer.addChild(leaderboardButton)
        
        
        /*** Middle Section ***/
        let yDist = ballWidth*1.35
        let topYLevel = (topMessage.frame.minY+restartButton.frame.maxY)*0.5+yDist*2.0
        
        // show ball 2-6
        if mergeBallNumArray.count <= 6 {
            // set up ball nodes
            let ballNode1 = BallNode(width: ballWidth*0.83, index: 2)
            let ballNode2 = BallNode(width: ballWidth*0.83, index: 3)
            let ballNode3 = BallNode(width: ballWidth*0.83, index: 4)
            let ballNode4 = BallNode(width: ballWidth*0.83, index: 5)
            let ballNode5 = BallNode(width: ballWidth*0.83, index: 6)
            
            ballNode1.position = CGPoint(x: safeAreaRect.width*0.3, y: topYLevel)
            ballNode2.position = CGPoint(x: safeAreaRect.width*0.3, y: topYLevel-yDist)
            ballNode3.position = CGPoint(x: safeAreaRect.width*0.3, y: topYLevel-yDist*2.0)
            ballNode4.position = CGPoint(x: safeAreaRect.width*0.3, y: topYLevel-yDist*3.0)
            ballNode5.position = CGPoint(x: safeAreaRect.width*0.3, y: topYLevel-yDist*4.0)
            
            gameOverLayer.addChild(ballNode1)
            gameOverLayer.addChild(ballNode2)
            gameOverLayer.addChild(ballNode3)
            gameOverLayer.addChild(ballNode4)
            gameOverLayer.addChild(ballNode5)
            
            // set up multiplier nodes
            print(mergeBallNumArray)
            let messageNum1 = mergeBallNumArray.count >= 2 ? mergeBallNumArray[1] : 0
            let messageNum2 = mergeBallNumArray.count >= 3 ? mergeBallNumArray[2] : 0
            let messageNum3 = mergeBallNumArray.count >= 4 ? mergeBallNumArray[3] : 0
            let messageNum4 = mergeBallNumArray.count >= 5 ? mergeBallNumArray[4] : 0
            let messageNum5 = mergeBallNumArray.count >= 6 ? mergeBallNumArray[5] : 0
            let messageNode1 = MessageNode(message: "x\(messageNum1)", fontName: FontNameType.Montserrat_Regular)
            let messageNode2 = MessageNode(message: "x\(messageNum2)", fontName: FontNameType.Montserrat_Regular)
            let messageNode3 = MessageNode(message: "x\(messageNum3)", fontName: FontNameType.Montserrat_Regular)
            let messageNode4 = MessageNode(message: "x\(messageNum4)", fontName: FontNameType.Montserrat_Regular)
            let messageNode5 = MessageNode(message: "x\(messageNum5)", fontName: FontNameType.Montserrat_Regular)
            
            let messageNodeWidth = ballWidth*3.0
            let messageNodeHeight = topMessageNodeHeight * 0.8
            
            let messageFrameX = safeAreaRect.width*0.7-ballNode1.size.width*0.5
            let topMessageNodeFrame1 = CGRect(x: messageFrameX,
                                              y: topYLevel-messageNodeHeight*0.5,
                                              width: messageNodeWidth,
                                              height: messageNodeHeight)
            messageNode1.zPosition = 100
            messageNode1.setFontColor(color: ColorCategory.getTopBarColor())
            messageNode1.adjustLabelFontSizeToFitRect(rect: topMessageNodeFrame1)
            messageNode1.setHorizontalAlignment(mode: .left)
            let messageFontSize = messageNode1.getFontSize()
            
            let topMessageNodeFrame2 = CGRect(x: messageFrameX,
                                              y: topYLevel-yDist-messageNodeHeight*0.5,
                                              width: messageNodeWidth,
                                              height: messageNodeHeight)
            messageNode2.zPosition = 100
            messageNode2.setFontColor(color: ColorCategory.getTopBarColor())
            messageNode2.adjustLabelFontSizeToFitRect(rect: topMessageNodeFrame2)
            messageNode2.setHorizontalAlignment(mode: .left)
            messageNode2.fontSize = messageFontSize
            
            let topMessageNodeFrame3 = CGRect(x: messageFrameX,
                                              y: topYLevel-yDist*2.0-messageNodeHeight*0.5,
                                              width: messageNodeWidth,
                                              height: messageNodeHeight)
            messageNode3.zPosition = 100
            messageNode3.setFontColor(color: ColorCategory.getTopBarColor())
            messageNode3.adjustLabelFontSizeToFitRect(rect: topMessageNodeFrame3)
            messageNode3.setHorizontalAlignment(mode: .left)
            messageNode3.fontSize = messageFontSize
            
            let topMessageNodeFrame4 = CGRect(x: messageFrameX,
                                              y: topYLevel-yDist*3.0-messageNodeHeight*0.5,
                                              width: messageNodeWidth,
                                              height: messageNodeHeight)
            messageNode4.zPosition = 100
            messageNode4.setFontColor(color: ColorCategory.getTopBarColor())
            messageNode4.adjustLabelFontSizeToFitRect(rect: topMessageNodeFrame4)
            messageNode4.setHorizontalAlignment(mode: .left)
            messageNode4.fontSize = messageFontSize
            
            let topMessageNodeFrame5 = CGRect(x: messageFrameX,
                                              y: topYLevel-yDist*4.0-messageNodeHeight*0.5,
                                              width: messageNodeWidth,
                                              height: messageNodeHeight)
            messageNode5.zPosition = 100
            messageNode5.setFontColor(color: ColorCategory.getTopBarColor())
            messageNode5.adjustLabelFontSizeToFitRect(rect: topMessageNodeFrame5)
            messageNode5.setHorizontalAlignment(mode: .left)
            messageNode5.fontSize = messageFontSize
            
            gameOverLayer.addChild(messageNode1)
            gameOverLayer.addChild(messageNode2)
            gameOverLayer.addChild(messageNode3)
            gameOverLayer.addChild(messageNode4)
            gameOverLayer.addChild(messageNode5)
            
        } else {
            
            // set up ball nodes
            let ballNode1 = BallNode(width: ballWidth*0.83, index: 2)
            let ballNode2 = BallNode(width: ballWidth*0.83, index: 3)
            let ballNode3 = ZLSpriteNode(height: ballWidth*0.65, image: "BallDots", color: ColorCategory.getTopBarColor())
            let ballNode4 = BallNode(width: ballWidth*0.83, index: mergeBallNumArray.count-1)
            let ballNode5 = BallNode(width: ballWidth*0.83, index: mergeBallNumArray.count)
            
            ballNode1.position = CGPoint(x: safeAreaRect.width*0.3, y: topYLevel)
            ballNode2.position = CGPoint(x: safeAreaRect.width*0.3, y: topYLevel-yDist)
            ballNode3.position = CGPoint(x: safeAreaRect.width*0.3, y: topYLevel-yDist*2.0)
            ballNode4.position = CGPoint(x: safeAreaRect.width*0.3, y: topYLevel-yDist*3.0)
            ballNode5.position = CGPoint(x: safeAreaRect.width*0.3, y: topYLevel-yDist*4.0)
            
            gameOverLayer.addChild(ballNode1)
            gameOverLayer.addChild(ballNode2)
            gameOverLayer.addChild(ballNode3)
            gameOverLayer.addChild(ballNode4)
            gameOverLayer.addChild(ballNode5)
            
            // set up multiplier nodes
            print(mergeBallNumArray)
            let messageNum1 = mergeBallNumArray[1]
            let messageNum2 = mergeBallNumArray[2]
            let messageNum4 = mergeBallNumArray[mergeBallNumArray.count-2]
            let messageNum5 = mergeBallNumArray[mergeBallNumArray.count-1]
            let messageNode1 = MessageNode(message: "x\(messageNum1)", fontName: FontNameType.Montserrat_Regular)
            let messageNode2 = MessageNode(message: "x\(messageNum2)", fontName: FontNameType.Montserrat_Regular)
            let messageNode3 = ZLSpriteNode(height: ballWidth*0.65, image: "BallDots", color: ColorCategory.getTopBarColor())
            let messageNode4 = MessageNode(message: "x\(messageNum4)", fontName: FontNameType.Montserrat_Regular)
            let messageNode5 = MessageNode(message: "x\(messageNum5)", fontName: FontNameType.Montserrat_Regular)
            
            let messageNodeWidth = ballWidth*3.0
            let messageNodeHeight = topMessageNodeHeight * 0.8
            
            let messageFrameX = safeAreaRect.width*0.7-ballNode1.size.width*0.5
            let topMessageNodeFrame1 = CGRect(x: messageFrameX,
                                              y: topYLevel-messageNodeHeight*0.5,
                                              width: messageNodeWidth,
                                              height: messageNodeHeight)
            messageNode1.zPosition = 100
            messageNode1.setFontColor(color: ColorCategory.getTopBarColor())
            messageNode1.adjustLabelFontSizeToFitRect(rect: topMessageNodeFrame1)
            messageNode1.setHorizontalAlignment(mode: .left)
            
            let topMessageNodeFrame2 = CGRect(x: messageFrameX,
                                              y: topYLevel-yDist-messageNodeHeight*0.5,
                                              width: messageNodeWidth,
                                              height: messageNodeHeight)
            messageNode2.zPosition = 100
            messageNode2.setFontColor(color: ColorCategory.getTopBarColor())
            messageNode2.adjustLabelFontSizeToFitRect(rect: topMessageNodeFrame2)
            messageNode2.setHorizontalAlignment(mode: .left)
            
            messageNode3.zPosition = 100
            messageNode3.position = CGPoint(x: safeAreaRect.width*0.7, y:topYLevel-yDist*2.0)
            
            let topMessageNodeFrame4 = CGRect(x: messageFrameX,
                                              y: topYLevel-yDist*3.0-messageNodeHeight*0.5,
                                              width: messageNodeWidth,
                                              height: messageNodeHeight)
            messageNode4.zPosition = 100
            messageNode4.setFontColor(color: ColorCategory.getTopBarColor())
            messageNode4.adjustLabelFontSizeToFitRect(rect: topMessageNodeFrame4)
            messageNode4.setHorizontalAlignment(mode: .left)
            
            let topMessageNodeFrame5 = CGRect(x: messageFrameX,
                                              y: topYLevel-yDist*4.0-messageNodeHeight*0.5,
                                              width: messageNodeWidth,
                                              height: messageNodeHeight)
            messageNode5.zPosition = 100
            messageNode5.setFontColor(color: ColorCategory.getTopBarColor())
            messageNode5.adjustLabelFontSizeToFitRect(rect: topMessageNodeFrame5)
            messageNode5.setHorizontalAlignment(mode: .left)
            
            gameOverLayer.addChild(messageNode1)
            gameOverLayer.addChild(messageNode2)
            gameOverLayer.addChild(messageNode3)
            gameOverLayer.addChild(messageNode4)
            gameOverLayer.addChild(messageNode5)
            
            
        }
        
        /*** fade in gameOverLayer ***/
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        fadeIn.timingMode = .easeIn
        gameOverLayer.run(fadeIn)
    }
    
    func gameEndBallEffect() {
        
        let scaleDown = SKAction.scale(to: 0.0, duration: 0.3)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        scaleDown.timingMode = .easeOut
        fadeOut.timingMode = .easeOut
        
        var iterCount = 0.0
        for ballNode in ballArray {
            delayWithSeconds(iterCount*0.1) {
                // add emitter
                let emitter = SKEmitterNode()
                let particleTexture = SKTexture(imageNamed: "Ball")
                emitter.particleSize = CGSize(width: self.ballWidth*0.17, height: self.ballWidth*0.17)
                emitter.particleTexture = particleTexture
                emitter.particleBirthRate = 150
                emitter.numParticlesToEmit = 15
                emitter.particleLifetime = 1.0
                emitter.emissionAngle = 0.0
                emitter.emissionAngleRange = CGFloat.pi*2
                emitter.particleSpeed = 80
                emitter.particleSpeedRange = 20
                emitter.particleAlpha = 0.6
                emitter.particleAlphaRange = 0.2
                emitter.particleAlphaSpeed = -0.7
                emitter.particleScale = 1.0
                emitter.particleScaleRange = 0.2
                emitter.particleScaleSpeed = -0.5
                emitter.particleColorBlendFactor = 1.0
                emitter.particleColor = ballNode.color
                emitter.particleColorBlendFactorSequence = nil
                emitter.particleBlendMode = SKBlendMode.alpha
                emitter.position = ballNode.position
                emitter.zPosition = 100
                self.centerNode.addChild(emitter)
                emitter.run(SKAction.sequence([SKAction.wait(forDuration: 1.0),
                                               SKAction.removeFromParent()]))
                
                
                // animate ball shadow
                ballNode.run(SKAction.group([scaleDown,fadeOut]),completion:{
                    ballNode.removeFromParent()
                })
                
                // add score
                self.incrementScore(by: ballNode.getScore(), from: ballNode)
                
            }
            // add iterCount
            iterCount += 1.0
        }
        
        delayWithSeconds(iterCount*0.1+0.6) {
            self.setUpGameOverLayer()
        }
    }
    
    
    //MARK:- Top Bar Handling
    func setUpTopBarNode() {
        // set up top score message node
        let scoreTopMessageNodeWidth = safeAreaRect.width*0.2
        let scoreTopMessageNodeHeight = topBarNode.size.height*0.15
        let scoreTopMessageNodeFrame = CGRect(x: -scoreTopMessageNodeWidth*0.5,
                                         y: -scoreTopMessageNodeHeight-5,
                                         width: scoreTopMessageNodeWidth,
                                         height: scoreTopMessageNodeHeight)
        let scoreTopMessage = MessageNode(message: "SCORE", fontName: FontNameType.Montserrat_SemiBold)
        scoreTopMessage.zPosition = 100
        scoreTopMessage.setFontColor(color: .white)
        scoreTopMessage.adjustLabelFontSizeToFitRect(rect: scoreTopMessageNodeFrame)
        topBarNode.addChild(scoreTopMessage)
        //debugDrawTopBarArea(rect: scoreTopMessageNodeFrame)
        
        // set up score message node
        let scoreMessageNodeWidth = safeAreaRect.width*0.3
        let scoreMessageNodeHeight = topBarNode.size.height*0.85-8
        let scoreMessageNodeFrame = CGRect(x: -scoreMessageNodeWidth*0.5,
                                              y: -topBarNode.size.height+3,
                                              width: scoreMessageNodeWidth,
                                              height: scoreMessageNodeHeight)
        scoreNode.zPosition = 100
        scoreNode.setFontColor(color: .white)
        scoreNode.adjustLabelFontSizeToFitRect(rect: scoreMessageNodeFrame)
        topBarNode.addChild(scoreNode)
        //debugDrawTopBarArea(rect: scoreMessageNodeFrame)
        
        // set up top high score message node
        let highScoreTopMessageNodeWidth = safeAreaRect.width*0.3
        let highScoreTopMessageNodeHeight = topBarNode.size.height*0.15
        let highScoreTopMessageNodeFrame = CGRect(x: -safeAreaRect.width*0.5+5,
                                                  y: -highScoreTopMessageNodeHeight-5,
                                                  width: highScoreTopMessageNodeWidth,
                                                  height: highScoreTopMessageNodeHeight)
        let highScoreTopMessage = MessageNode(message: "HIGH SCORE", fontName: FontNameType.Montserrat_SemiBold)
        highScoreTopMessage.zPosition = 100
        highScoreTopMessage.setFontColor(color: .white)
        highScoreTopMessage.adjustLabelFontSizeToFitRect(rect: highScoreTopMessageNodeFrame)
        highScoreTopMessage.setHorizontalAlignment(mode: .left)
        topBarNode.addChild(highScoreTopMessage)
        //debugDrawTopBarArea(rect: highScoreTopMessageNodeFrame)
        
        // set up best score message node
        let bestScoreMessageNodeWidth = safeAreaRect.width*0.23
        let bestScoreMessageNodeHeight = topBarNode.size.height*0.35
        let bestScoreMessageNodeFrame = CGRect(x: -safeAreaRect.width*0.5+5,
                                           y: -topBarNode.size.height+topBarNode.size.height*0.24,
                                           width: bestScoreMessageNodeWidth,
                                           height: bestScoreMessageNodeHeight)
        bestScoreNode.setText(to: "\(self.bestScore)")
        bestScoreNode.zPosition = 100
        bestScoreNode.setFontColor(color: .white)
        bestScoreNode.adjustLabelFontSizeToFitRect(rect: bestScoreMessageNodeFrame)
        bestScoreNode.setHorizontalAlignment(mode: .left)
        topBarNode.addChild(bestScoreNode)
        //debugDrawTopBarArea(rect: bestScoreMessageNodeFrame)
        
        // set up combo node
        let comboNodeWidth = safeAreaRect.width*0.25
        let comboNodeHeight = topBarNode.size.height*0.46
        let comboNodeFrame = CGRect(x: safeAreaRect.width*0.47-comboNodeWidth,
                                    y: -topBarNode.size.height+topBarNode.size.height*0.27,
                                    width: comboNodeWidth,
                                    height: comboNodeHeight)
        comboNode.zPosition = 100
        comboNode.adjustLabelFontSizeToFitRect(rect: comboNodeFrame)
        topBarNode.addChild(comboNode)
        //debugDrawTopBarArea(rect: comboNodeFrame)
     
        // set up next ball message node
        let nextBallMessageNodeWidth = safeAreaRect.width*0.25
        let nextBallMessageNodeHeight = topBarNode.size.height*0.15
        let nextBallMessageNodeFrame = CGRect(x: -safeAreaRect.width*0.5+5,
                                              y: -topBarNode.size.height-highScoreTopMessageNodeHeight-5,
                                              width: nextBallMessageNodeWidth,
                                             height: nextBallMessageNodeHeight)
        let nextBallMessage = MessageNode(message: "NEXT", fontName: FontNameType.Montserrat_SemiBold)
        nextBallMessage.name = "nextBallMessage"
        nextBallMessage.zPosition = 100
        nextBallMessage.setFontColor(color: ColorCategory.getTopBarColor())
        nextBallMessage.adjustLabelFontSizeToFitRect(rect: nextBallMessageNodeFrame)
        nextBallMessage.setHorizontalAlignment(mode: .left)
        topBarNode.addChild(nextBallMessage)
        //debugDrawTopBarArea(rect: highScoreTopMessageNodeFrame)
    }
        
    //MARK:- Pause Menu Handling
    func setUpPauseLayer() {
        /*** set up pause layer ***/
        // add white mask to background
        let blurBackgroundNode = SKSpriteNode(color: SKColor.white.withAlphaComponent(0.70), size: CGSize(width: size.width, height: size.height))
        blurBackgroundNode.zPosition = 6000
        blurBackgroundNode.position = CGPoint(x:size.width/2 ,y: size.height/2)
        pauseLayer.addChild(blurBackgroundNode)
        
        // calculate button numbers
        let verticleDistance = min(safeAreaRect.size.width*0.1818,safeAreaRect.size.height*0.1023)
        let buttonWidth = min(safeAreaRect.size.width*0.5,safeAreaRect.size.height*0.281)
        
        // add continue button
        let resumeButton = MenuButtonNode(color: ColorCategory.BallColor3,
                                          buttonType: ButtonType.LongButton,
                                          iconType: IconType.ResumeButton,
                                          width: buttonWidth)
        resumeButton.zPosition = 10000
        resumeButton.position = CGPoint(x: safeAreaRect.width/2,
                                        y: safeAreaRect.height/2 + verticleDistance*1.5)
        resumeButton.name = "resumebutton"
        resumeButton.buttonDelegate = self
        pauseLayer.addChild(resumeButton)
        
        // add restart button
        let restartButton = MenuButtonNode(color: ColorCategory.BallColor1,
                                           buttonType: ButtonType.LongButton,
                                           iconType: IconType.SmallRestartButton,
                                           width: buttonWidth)
        restartButton.zPosition = 10000
        restartButton.position = CGPoint(x: safeAreaRect.width/2,
                                         y: safeAreaRect.height/2 + verticleDistance*0.5)
        restartButton.name = "restartbutton"
        restartButton.buttonDelegate = self
        pauseLayer.addChild(restartButton)
        
        // add stop button
        let stopButton = MenuButtonNode(color: ColorCategory.BallColor2,
                                        buttonType: ButtonType.LongButton,
                                        iconType: IconType.StopButton,
                                        width: buttonWidth)
        stopButton.zPosition = 10000
        stopButton.position = CGPoint(x: safeAreaRect.width/2,
                                      y: safeAreaRect.height/2 - verticleDistance*0.5)
        stopButton.name = "stopbutton"
        stopButton.buttonDelegate = self
        pauseLayer.addChild(stopButton)
        
        // add music button
        var iconTypeHere = IconType.MusicOnButton
        iconTypeHere = gameMusicOn ? IconType.MusicOnButton : IconType.MusicOffButton
        let musicButton = MenuButtonNode(color: ColorCategory.BallColor4,
                                         buttonType: ButtonType.ShortButton,
                                         iconType: iconTypeHere,
                                         width: buttonWidth*0.4545)
        musicButton.zPosition = 10000
        musicButton.position = CGPoint(x: safeAreaRect.width/2-resumeButton.size.width/2+musicButton.size.width/2,
                                       y: safeAreaRect.height/2 - verticleDistance*1.5)
        musicButton.name = "musicbutton"
        musicButton.buttonDelegate = self
        pauseLayer.addChild(musicButton)
        
        // add sound button
        iconTypeHere = gameSoundOn ? IconType.SoundOnButton : IconType.SoundOffButton
        let soundButton = MenuButtonNode(color: ColorCategory.BallColor5,
                                         buttonType: ButtonType.ShortButton,
                                         iconType: iconTypeHere,
                                         width: buttonWidth*0.4545)
        soundButton.zPosition = 10000
        soundButton.position = CGPoint(x: safeAreaRect.width/2+resumeButton.size.width/2-musicButton.size.width/2,
                                       y: safeAreaRect.height/2 - verticleDistance*1.5)
        soundButton.name = "soundbutton"
        soundButton.buttonDelegate = self
        pauseLayer.addChild(soundButton)
        
    }
    
    func pauseButton() {
        if !isGameStart {
            return
        }
        
        // pause everything
        gameLayer.isPaused = true
        for child in gameLayer.children {
            child.isPaused = true
        }
        physicsWorld.speed = 0.0
        
        pauseLayer.position = CGPoint(x:0.0, y:bottomSafeSets)
        self.addChild(pauseLayer)
        pauseLayer.name = "pauselayer"
    }
    
    func unpauseButton() {
        if !isGameStart {
            return
        }
        
        // unpause everything
        gameLayer.isPaused = false
        for child in gameLayer.children {
            child.isPaused = false
        }
        physicsWorld.speed = 1.0
        
        // unpause scene
        self.scene?.isPaused = false
        pauseLayer.removeFromParent()
        self.scene?.isPaused = false
    }
    
    
    //MARK:- ControlButtonDelegate Func
    func controlButtonWasPressed(sender: ControlButtonNode) {
        // play sound
        if gameSoundOn {
            self.run(buttonPressedSound)
        }
        
        // Case 1. Pause button pressed
        if sender.getControlButtonType() == ControlButtonType.PauseButton {
            //print("pauseButtonWasPressed")
            //if !isGameOver {
                if isGamePaused {
                    unpauseButton()
                } else {
                    pauseButton()
                }
                isGamePaused = !isGamePaused
            //}
            
            return
        }
        
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
        if iconType == IconType.MusicOnButton  {
            gameMusicOn = true
            /*** play background music */
            NotificationCenter.default.post(name: Notification.Name(rawValue: "resumeBackgroundSound"), object: nil)
            return
        }
        if iconType == IconType.MusicOffButton  {
            gameMusicOn = false
            /*** pause background music */
            NotificationCenter.default.post(name: Notification.Name(rawValue: "pauseBackgroundSound"), object: nil)
            return
        }
        if iconType == IconType.ResumeButton  {
            if isGamePaused {
                unpauseButton()
                isGamePaused = false
            }
            return
        }
        if iconType == IconType.HomeButton  {
            if view != nil {
                let scene = GameScene(size: size)
                scene.isAdReady = self.isAdReady
                let transition:SKTransition = SKTransition.fade(withDuration: 0.5)
                self.view?.presentScene(scene, transition: transition)
            }
            return
        }
        if iconType == IconType.SmallRestartButton  {
            if view != nil {
                let scene = GameScene(size: size)
                scene.isAdReady = self.isAdReady
                //scene.isRestarting = true
                let transition:SKTransition = SKTransition.fade(withDuration: 0.5)
                self.view?.presentScene(scene, transition: transition)
            }
            return
        }
        if iconType == IconType.StopButton  {
            //unpauseButton()
            //gameOver()
            return
        }
        if iconType == IconType.ShareButton  {
            /*** take snapshot ***/
            self.postImage  = self.view?.pb_takeSnapshot()
            //Photos
            let photos = PHPhotoLibrary.authorizationStatus()
            if photos == .notDetermined {
                PHPhotoLibrary.requestAuthorization({status in
                    if status == .authorized{
                        self.isPhotoPermission = true
                        self.presentShareSheet()
                        return
                    } else {}
                })
            } else if photos == .authorized {
                isPhotoPermission = true
                self.presentShareSheet()
            } else {
                showAlert(withTitle: "No Permission to Photos", message: "Giving permission will let you save and share game screenshots. This can be configured in Settings.")
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
                    if products == nil || products?.count != 4 {
                        let userInfoDict:[String: String] = ["forButton": "iapfail"]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "displayAlertMessage"), object: nil, userInfo: userInfoDict)
                        return
                    }
                    self.products = products!
                    
                    // buy selected product
                    for index in 0..<4 {
                        let thisProduct = self.products[index] as SKProduct
                        if thisProduct.productIdentifier == IAPProducts.NoAds {
                            IAPProducts.store.buyProduct(thisProduct)
                            return
                        }
                    }
                    
                }
            }
            return
        }
        if iconType == IconType.RestoreIAPButton  {
            IAPProducts.store.restorePurchases()
            return
        }
        if iconType == IconType.StoreButton {
            if view != nil {
                let transition:SKTransition = SKTransition.fade(withDuration: 0.5)
                let storeScene = StoreScene(size: self.size)
                storeScene.isAdReady = self.isAdReady
                self.view?.presentScene(storeScene, transition: transition)
            }
            return
        }
    }
    
    
    //MARK:- Helper Functions
    @objc func applicationWillResignActive() {
        
    }
    
    @objc func applicationDidBecomeActive(){
        
    }
    
    func schemeAvailable(_ scheme: String) -> Bool {
        if let url = URL(string: scheme) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    
    
    func debugDrawArea(rect drawRect: CGRect) {
        let shape = SKShapeNode(rect: drawRect)
        shape.strokeColor = SKColor.red
        shape.lineWidth = 2.0
        gameLayer.addChild(shape)
    }
    
    
    func debugDrawTopBarArea(rect drawRect: CGRect) {
        let shape = SKShapeNode(rect: drawRect)
        shape.strokeColor = SKColor.red
        shape.lineWidth = 2.0
        topBarNode.addChild(shape)
    }
    
    
    func debugPrintBallArray(ballArray: [BallNode]) {
        print("----- BallArray -----")
        if ballArray.count==0 {
            print("(empty)")
            return
        }
        for iterCount in 0..<ballArray.count-1 {
            print("(\(iterCount).\(ballArray[iterCount].getIndex()):\(Int(ballArray[iterCount].getRotationAngle()*180/CGFloat.pi)))", terminator:",")
        }
        print("(\(ballArray.count-1).\(ballArray[ballArray.count-1].getIndex()):\(Int(ballArray[ballArray.count-1].getRotationAngle()*180/CGFloat.pi)))")
        print("---------------------")
    }
    
    func distBetweenTwoAngles(_ angle1: CGFloat, _ angle2: CGFloat) -> CGFloat {
        let value1 = abs(angle1-angle2)
        let value2 = abs(angle1-angle2+CGFloat.pi*2.0)
        let value3 = abs(angle2-angle1+CGFloat.pi*2.0)
        
        return min(value1, value2, value3)
    }
    
    func distBetweenTwoPoints(_ point1: CGPoint, _ point2: CGPoint) -> CGFloat {
        return sqrt((point1.x-point2.x)*(point1.x-point2.x)+(point1.y-point2.y)*(point1.y-point2.y))
    }
    
    // check if some nodes are running across other nodes for matching 3
    func isRunningAcrossOtherNodes3(newAngle newRotationAngle: CGFloat, forIndex index: Int, removeArrayIndex: [Int], angleAdj: CGFloat) -> (Bool, [CGFloat]) {
        
        // define the angles of ball nodes to be removed
        var removalAngle1 = ballArray[removeArrayIndex[0]].getRotationAngle()
        var removalAngle2 = ballArray[removeArrayIndex[1]].getRotationAngle()
        var removalAngle3 = ballArray[removeArrayIndex[2]].getRotationAngle()
        
        // adjust removal angles
        if angleAdj < 0 {
            // case 1. decrease the largest value
            if removalAngle1 > removalAngle2, removalAngle1 > removalAngle3 {
                removalAngle1 = removalAngle1 + angleAdj
            } else if removalAngle2 > removalAngle1, removalAngle2 > removalAngle3 {
                removalAngle2 = removalAngle2 + angleAdj
            } else if removalAngle3 > removalAngle1, removalAngle3 > removalAngle2 {
                removalAngle3 = removalAngle3 + angleAdj
            }
        } else if angleAdj > 0 {
            // case 2. increase the smallest value
            if removalAngle1 < removalAngle2, removalAngle1 < removalAngle3 {
                removalAngle1 = removalAngle1 + angleAdj
            } else if removalAngle2 < removalAngle1, removalAngle2 < removalAngle3 {
                removalAngle2 = removalAngle2 + angleAdj
            } else if removalAngle3 < removalAngle1, removalAngle3 < removalAngle2 {
                removalAngle3 = removalAngle3 + angleAdj
            }
        }
        
        // find the max and min angles
        let minAngle = min(removalAngle1,removalAngle2,removalAngle3,newRotationAngle)
        let maxAngle = max(removalAngle1,removalAngle2,removalAngle3,newRotationAngle)
        
        // if there's a ball of different color inbetween, return true
        for aBallNode in ballArray {
            if minAngle < aBallNode.getRotationAngle(),
                maxAngle > aBallNode.getRotationAngle(),
                aBallNode.getIndex() != index {
                return (true,[removalAngle1,removalAngle2,removalAngle3])
            }
            if minAngle < aBallNode.getRotationAngle()+angleAdj,
                maxAngle > aBallNode.getRotationAngle()+angleAdj,
                aBallNode.getIndex() != index {
                return (true,[removalAngle1,removalAngle2,removalAngle3])
            }
        }
        
        return (false,[removalAngle1,removalAngle2,removalAngle3])
    }
    
    // check if some nodes are running across other nodes for matching 2
    func isRunningAcrossOtherNodes2(newAngle newRotationAngle: CGFloat, forIndex index: Int, removeArrayIndex: [Int], angleAdj: CGFloat) -> (Bool, [CGFloat]) {
        
        // define the angles of ball nodes to be removed
        var removalAngle1 = ballArray[removeArrayIndex[0]].getRotationAngle()
        var removalAngle2 = ballArray[removeArrayIndex[1]].getRotationAngle()
        
        // adjust removal angles
        if angleAdj < 0 {
            // case 1. decrease the largest value
            if removalAngle1 > removalAngle2 {
                removalAngle1 = removalAngle1 + angleAdj
            } else if removalAngle2 >= removalAngle1 {
                removalAngle2 = removalAngle2 + angleAdj
            }
        } else if angleAdj > 0 {
            // case 2. increase the smallest value
            if removalAngle1 < removalAngle2 {
                removalAngle1 = removalAngle1 + angleAdj
            } else if removalAngle2 <= removalAngle1 {
                removalAngle2 = removalAngle2 + angleAdj
            }
        }
        
        // find the max and min angles
        let minAngle = min(removalAngle1,removalAngle2,newRotationAngle)
        let maxAngle = max(removalAngle1,removalAngle2,newRotationAngle)
        
        // if there's a ball of different color inbetween, return true
        for aBallNode in ballArray {
            if minAngle < aBallNode.getRotationAngle(),
                maxAngle > aBallNode.getRotationAngle(),
                aBallNode.getIndex() != index {
                return (true,[removalAngle1,removalAngle2])
            }
            if minAngle < aBallNode.getRotationAngle()+angleAdj,
                maxAngle > aBallNode.getRotationAngle()+angleAdj,
                aBallNode.getIndex() != index {
                return (true,[removalAngle1,removalAngle2])
            }
        }
        
        return (false,[removalAngle1,removalAngle2])
    }
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }

    
    func presentShareSheet() {
        let postText: String = "Check out my score! I got \(gameScore) points in Balls vs Cups! #OrbitMerge #RawwrStudios"
        // append h ttps://itunes.apple.com/app/circle/id911152486
        var activityItems : [Any]
        if let postImage = postImage, isPhotoPermission{
            activityItems = [postText, postImage] as [Any]
        } else {
            activityItems = [postText]
        }
        
        let activityController = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        UIApplication.topViewController()?.present(
            activityController,
            animated: true,
            completion: nil
        )
    }
    
    //sends the highest score to leaderboard
    func postToLeaderBoard(gameScore: Int) {
        print("Highscore postToLeaderBoard!")
        
        if GKLocalPlayer.localPlayer().isAuthenticated {
            
            let scoreReporter = GKScore(leaderboardIdentifier: "OrbitMerge")
            scoreReporter.value = Int64(gameScore)
            let scoreArray: [GKScore] = [scoreReporter]
            
            GKScore.report(scoreArray, withCompletionHandler: {error -> Void in
                if error != nil {
                    print("An error has occured: \(String(describing: error))")
                }
            })
        }
    }
    
    
    //MARK:- Rewarded Ads
    func enableAdsSaveMe() {
        isAdReady = true
    }
    
    func disableAdsSaveMe() {
        isAdReady = false
    }
    
    func performAdsSaveMe() {
        print("gamescene performAdsSaveMeAction")
    }
}

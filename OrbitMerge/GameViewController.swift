//
//  GameViewController.swift
//  OrbitMerge
//
//  Created by Alan Lou on 8/26/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit
import Firebase

class GameViewController: UIViewController, GKGameCenterControllerDelegate, GADBannerViewDelegate, GADInterstitialDelegate, GADRewardBasedVideoAdDelegate {

    @IBOutlet weak var logoView: UIImageView!
    
    // declare a property to keep a reference to the SKView
    var skView: SKView!
    
    // The ads view
    var bannerView: GADBannerView!
    var interstitial: GADInterstitial!
    var rewardBasedVideo: GADRewardBasedVideoAd?
    /// Is an ad being loaded
    var adRequestInProgress: Bool = false
    /// Is an ad ready
    var isAdReady: Bool = false
    
    // Variables
    var didWatchRewardAds: Bool = false
    
    // Ads Unit ID
    // Banner Ad unit ID (Test): ca-app-pub-3940256099942544/2934735716
    // Banner Ad unit ID (OrbitMerge): ca-app-pub-5422633750847690/2469010543
    let bannerAdsUnitID = "ca-app-pub-5422633750847690/2469010543"
    // Reward Ad unit ID (Test): ca-app-pub-3940256099942544/1712485313
    // Reward Ad unit ID (OrbitMerge): ca-app-pub-5422633750847690/2478100476
    let rewardAdsUnitID = "ca-app-pub-5422633750847690/2478100476"
    // Interstitial Ad unit ID (Test): ca-app-pub-3940256099942544/4411468910
    // Interstitial Ad unit ID (OrbitMerge): ca-app-pub-5422633750847690/5641968795
    let gameFinishAdsUnitID = "ca-app-pub-5422633750847690/5641968795"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set justOpenApp indicator
        UserDefaults.standard.set(true, forKey: "justOpenApp")
        
        let noAdsPurchased = UserDefaults.standard.bool(forKey: "noAdsPurchased")
        
        // noAds NOT purchased
        if !noAdsPurchased {
            
            // Set up banner with desired ad size
            // Smart Banner: Screen width x 32|50|90
            bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
            
            if UserDefaults.standard.float(forKey: "AdsHeight") == 0.0 {
                UserDefaults.standard.set(bannerView.frame.height, forKey: "AdsHeight")
            }
            
            bannerView.adUnitID = self.bannerAdsUnitID
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            bannerView.delegate = self
            
            interstitial = createAndLoadInterstitial()
        }
        
        // Add reward ads observer
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(removeBannerAds),
                                               name: Notification.Name(rawValue: "removeBannerAds"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(runInterstitialAds),
                                               name: Notification.Name(rawValue: "runInterstitialAds"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(runRewardsAds),
                                               name: Notification.Name(rawValue: "runRewardAds"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(displayAlertMessage(notification:)),
                                               name: Notification.Name(rawValue: "displayAlertMessage"),
                                               object: nil)
        
        // prepare rewards ads
        prepareRewardsAds()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let justOpenApp = UserDefaults.standard.bool(forKey: "justOpenApp")
        
        if justOpenApp {
            UserDefaults.standard.set(false, forKey: "justOpenApp")
            
            let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
            // first time launching
            if !launchedBefore  {
                //print("WELCOME! FIRST TIME LAUNCHING!")
                setUpFirstLaunch()
            }
            
            /*** display logo view ***/
            self.view.backgroundColor = .clear
            
            logoView.isHidden = false
            logoView.alpha = 1.0
            
            /*** initialize Main ***/
            let scene = MenuScene(size: self.view.bounds.size) // match the device's size
            scene.isFirstTimeOpening = !launchedBefore
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            if let view = self.view as! SKView? {
                // present game scene
                self.skView = view
                //skView.showsFPS = true
                //skView.showsPhysics = true
                //skView.showsNodeCount = true
                self.skView.ignoresSiblingOrder = true
                
                scene.isAdReady = self.isAdReady
                scene.alpha = 0.0
                self.skView.presentScene(scene)
            }
            
            // Then fades the logo away after 1 seconds (the cross-fade animation will take 0.5s)
            UIView.animate(withDuration: 0.2, delay: 1.0, options: [], animations: {
                self.logoView.alpha = 0.0
            }) { (finished: Bool) in
                self.logoView.isHidden = true
                
                // For Gamecenter
                self.authenticateLocalPlayer()
                
                let fadeIn = SKAction.fadeIn(withDuration: 0.5)
                scene.run(fadeIn)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    //MARK:- GADBannerViewDelegate
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        //print("adViewDidReceiveAd")
        addBannerViewToView(bannerView)
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        if #available(iOS 11.0, *) {
            // In iOS 11, we need to constrain the view to the safe area.
            positionBannerViewFullWidthAtBottomOfSafeArea(bannerView)
        }
        else {
            // In lower iOS versions, safe area is not available so we use
            // bottom layout guide and view edges.
            positionBannerViewFullWidthAtBottomOfView(bannerView)
        }
    }
    
    // MARK: - view positioning
    @available (iOS 11, *)
    func positionBannerViewFullWidthAtBottomOfSafeArea(_ bannerView: UIView) {
        // Position the banner. Stick it to the bottom of the Safe Area.
        // Make it constrained to the edges of the safe area.
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            guide.leftAnchor.constraint(equalTo: bannerView.leftAnchor),
            guide.rightAnchor.constraint(equalTo: bannerView.rightAnchor),
            guide.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor)
            ])
    }
    
    func positionBannerViewFullWidthAtBottomOfView(_ bannerView: UIView) {
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: 0))
        if #available(iOS 11.0, *) {
            view.addConstraint(NSLayoutConstraint(item: bannerView,
                                                  attribute: .bottom,
                                                  relatedBy: .equal,
                                                  toItem: view.safeAreaLayoutGuide.bottomAnchor,
                                                  attribute: .bottom,
                                                  multiplier: 1,
                                                  constant: 0))
        } else {
            // Fallback on earlier versions
            view.addConstraint(NSLayoutConstraint(item: bannerView,
                                                  attribute: .bottom,
                                                  relatedBy: .equal,
                                                  toItem: view,
                                                  attribute: .bottom,
                                                  multiplier: 1,
                                                  constant: 0))
        }
    }
    
    
    //MARK:- GADRewardBasedVideoAdDelegate
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didFailToLoadWithError error: Error) {
        adRequestInProgress = false
        //print("Reward based video ad failed to load: \(error.localizedDescription)")
        // load again
        if !adRequestInProgress && rewardBasedVideo?.isReady == false {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                // request new ads
                self?.rewardBasedVideo?.load(GADRequest(),
                                             withAdUnitID: (self?.rewardAdsUnitID)!)
                self?.adRequestInProgress = true
            }
        }
    }
    
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        adRequestInProgress = false
        isAdReady = true
        //print("Reward based video ad is received.")
        
        // check to see if the current scene is the game scene
        if let gameScene = skView.scene as? GameScene {
            gameScene.enableAdsSaveMe()
        }
        if let menuScene = skView.scene as? MenuScene {
            menuScene.isAdReady = true
        }
        if let storeScene = skView.scene as? StoreScene {
            storeScene.enableWatchVideo()
        }
    }
    
    func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        //print("Opened reward based video ad.")
    }
    
    func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        //print("Reward based video ad started playing.")
        
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        //print("Reward based video ad is closed.")
        
        isAdReady = false
        prepareRewardsAds()
        
        // check to see if the current scene is the game scene
        if let gameScene = skView.scene as? GameScene, didWatchRewardAds {
            //print("performAdsSaveMe")
            gameScene.performAdsSaveMe()
        }
        
        if let gameScene = skView.scene as? GameScene, !didWatchRewardAds {
            //print("gameOver")
            gameScene.gameOver()
        }
        
        // watched video to add coins
        if let storeScene = skView.scene as? StoreScene, didWatchRewardAds {
            storeScene.performAdsAddCoins()
            storeScene.disableWatchVideo()
        }
        
        if let storeScene = skView.scene as? StoreScene, !didWatchRewardAds {
            storeScene.disableWatchVideo()
        }
        
        didWatchRewardAds = false
    }
    
    func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        //print("Reward based video ad will leave application.")
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        //print("Reward received with currency: \(reward.type), amount \(reward.amount).")
        
        didWatchRewardAds = true
    }
    
    //MARK:- Prepare and Run Reward Video Ads
    func prepareRewardsAds() {
        print("PREPARE ADS!")
        rewardBasedVideo = GADRewardBasedVideoAd.sharedInstance()
        rewardBasedVideo?.delegate = self
        
        if !adRequestInProgress && rewardBasedVideo?.isReady == false {
            rewardBasedVideo?.load(GADRequest(),
                                   withAdUnitID: rewardAdsUnitID)
            adRequestInProgress = true
        }
    }
    
    @objc func runRewardsAds() {
        if rewardBasedVideo?.isReady == true {
            rewardBasedVideo?.present(fromRootViewController: self)
        }
    }
    
    @objc func removeBannerAds() {
        //print("Remove Banner Ads!")
        if bannerView == nil {
            return
        }
        UserDefaults.standard.set(0.0, forKey: "AdsHeight")
        self.bannerView.removeFromSuperview()
        self.view.setNeedsDisplay()
    }
    
    //MARK:- Interstitial Ads
    func createAndLoadInterstitial() -> GADInterstitial {
        //print("Create and Load Interstitial Ads!")
        let interstitial = GADInterstitial(adUnitID: gameFinishAdsUnitID)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    @objc func runInterstitialAds() {
        if interstitial == nil {
            return
        }
        if self.interstitial.isReady {
            self.interstitial.present(fromRootViewController: self)
        } else {
            //print("Interstitial Ad wasn't ready")
            interstitial = createAndLoadInterstitial()
        }
        
    }
    
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        //print("interstitialDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        //print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        //print("interstitialWillPresentScreen")
        // Log Event
        Analytics.logEvent("ad_gameend_start", parameters: [:])
    }
    
    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        //print("interstitialWillDismissScreen")
    }
    
    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        //print("interstitialDidDismissScreen")
        
        // Log Event
        Analytics.logEvent("ad_gameend_finish", parameters: [:])
        interstitial = createAndLoadInterstitial()
    }
    
    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        //print("interstitialWillLeaveApplication")
    }
    
    //MARK:- Alert Message
    @objc func displayAlertMessage(notification:NSNotification) {
        if let userInfo = notification.userInfo {
            let message = userInfo["forButton"] as! String
            
            // Case 1. display alert view for like
            if message == "like" {
                let alertController = UIAlertController(title: "Enjoy 2048 Ball Blast?", message: "Please rate the game to support us. Thank you!", preferredStyle: .alert)
                let actionYes = UIAlertAction(title: "Yes, I like it!", style: .default) {
                    UIAlertAction in
                    self.rateApp(appId: "id1437084392") { success in
                        //print("RateApp \(success)")
                    }
                }
                let actionNo = UIAlertAction(title: "No, thanks.", style: .default) {
                    UIAlertAction in
                }
                
                alertController.addAction(actionYes)
                alertController.addAction(actionNo)
                
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            
            // Case 2. display alert view for leaderboard
            if message == "leaderboard" {
                showLeaderboard()
                
                return
            }
            
            // Case 3. iap failed
            if message == "iapfail" {
                let alertController = UIAlertController(title: "Purchase Failed", message: "Ooops, something went wrong. Please try again later. Thank you!", preferredStyle: .alert)
                let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) {
                    UIAlertAction in
                    //                    NSLog("Cancel Pressed")
                }
                alertController.addAction(actionCancel)
                
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            
            // Case 4. buy new ball
            if message == "buyNewBall" {
                let alertController = UIAlertController(title: "Time for New Skin!", message: "Do you want to buy new skin for 100 coins?", preferredStyle: .alert)
                let actionYes = UIAlertAction(title: "Yes", style: .default) {
                    UIAlertAction in
                    // purchase succeed
                    if let storeScene = self.skView.scene as? StoreScene {
                        storeScene.buyANewMode()
                    }
                }
                let actionLater = UIAlertAction(title: "Cancel", style: .cancel) {
                    UIAlertAction in
                }
                alertController.addAction(actionYes)
                alertController.addAction(actionLater)
                
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            
            // Case 5. not enough coin
            if message == "notEnoughCoins" {
                let alertController = UIAlertController(title: "Ooops", message: "Get more coins and come back later!", preferredStyle: .alert)
                let actionOkay = UIAlertAction(title: "Okay", style: .cancel) {
                    UIAlertAction in
                }
                alertController.addAction(actionOkay)
                
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            
        }
    }
    
    //MARK:- Helper Function
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: completion)
    }
    
    func authenticateLocalPlayer() {
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            
            if (viewController != nil) {
                self.present(viewController!, animated: true, completion: nil)
            }
            else {
                //print((GKLocalPlayer.localPlayer().isAuthenticated))
            }
        }
    }
    
    func showLeaderboard() {
        //print("show leaderboard")
        let gKGCViewController = GKGameCenterViewController()
        gKGCViewController.gameCenterDelegate = self as GKGameCenterControllerDelegate
        self.present(gKGCViewController, animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    func setUpFirstLaunch() {
        UserDefaults.standard.set(false, forKey: "justOpenApp")
        UserDefaults.standard.set(false, forKey: "gameInProgress")
        UserDefaults.standard.set(false, forKey: "noAdsPurchased")
        UserDefaults.standard.set(true, forKey: "launchedBefore")
        UserDefaults.standard.set(0, forKey: "highScore")
        UserDefaults.standard.set(0, forKey: "highCombo")
        UserDefaults.standard.set(1, forKey: "highBallNum")
        UserDefaults.standard.set("Simple", forKey: "mode")
        
        // configure default balls
        let Mode0 = ModeItem(identifier: "Simple", isBought: true)
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: Mode0)
        UserDefaults.standard.set(encodedData, forKey: "Simple")
        UserDefaults.standard.set(encodedData, forKey: "SelectedMode")
        
        
        // configure mode library
        configureModeItem(key: "Modern")
        configureModeItem(key: "Warm")
        configureModeItem(key: "Bright")
        configureModeItem(key: "Dark")
        configureModeItem(key: "Mint")
    }
    
    func configureModeItem(key keyTemp: String) {
        let aModeItem = ModeItem(identifier: keyTemp, isBought: false)
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: aModeItem)
        UserDefaults.standard.set(encodedData, forKey: keyTemp)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

//
//  DefaultValues.swift
//  BreakoutDraw
//
//  Created by Alan Lou on 7/12/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import SpriteKit

struct ColorCategory {
    // Background Colors
    static let BackgroundColor_Dark = SKColor(red: 24/255, green: 24/255, blue: 36/255, alpha: 1.0)
    static let BackgroundColor_Bright = SKColor(red: 245/255, green: 238/255, blue: 233/255, alpha: 1.0)
    
    // Top Bar Colors
    static let TopBarColor_Dark = SKColor(red: 40/255, green: 44/255, blue: 63/255, alpha: 1.0)
    static var TopBarColor_Bright = SKColor(red: 212/255, green:147/255, blue: 129/255, alpha: 1.0)
    
    // Store Scene Cell Background
    static let CellBackgroundColor_Dark = TopBarColor_Dark
    static var CellBackgroundColor_Bright = TopBarColor_Bright
    
    // Line Colors
    static var LineColor_Dark = SKColor(red: 127/255, green:127/255, blue: 127/255, alpha: 1.0)
    static var LineColor_Bright = TopBarColor_Bright
    
    // Message Colors
    static var MessageFontColor_Dark = SKColor(red: 255/255, green:255/255, blue: 255/255, alpha: 1.0)
    static var MessageFontColor_Bright = TopBarColor_Bright
    
    // Text Colors
    static var TextFontColor_Dark = LineColor_Dark.withAlphaComponent(0.8)
    static var TextFontColor_Bright = LineColor_Bright
    
    // Control Button Colors
    static var ControlButtonColor_Dark = UIColor.white
    static var ControlButtonColor_Bright = SKColor(red: 129/255, green:110/255, blue: 107/255, alpha: 1.0)
    
    // Title Color
    static let TitleColor1 = SKColor(red: 244/255, green:38/255, blue: 94/255, alpha: 1.0) //SKColor(red: 253/255, green:206/255, blue: 51/255, alpha: 1.0)
    static let TitleColor2 = SKColor(red: 246/255, green:185/255, blue: 65/255, alpha: 1.0)
    static let TitleColor3 = SKColor(red: 0/255, green:116/255, blue: 185/255, alpha: 1.0)
    
    // Button Color
    static let ContinueButtonColor = SKColor(red: 255/255, green: 127/255, blue: 129/255, alpha: 1.0)
    
    // Ball Colors
    static var InitialBallColor = SKColor(red: 212/255, green:147/255, blue: 129/255, alpha: 1.0)
    static let BallColor1 = SKColor(red: 249/255, green:180/255, blue: 80/255, alpha: 1.0) // 2
    static let BallColor2 = SKColor(red: 128/255, green:175/255, blue: 163/255, alpha: 1.0) // 4
    static let BallColor3 = SKColor(red: 241/255, green:111/255, blue: 127/255, alpha: 1.0) // 8
    static let BallColor4 = SKColor(red: 89/255, green:156/255, blue: 188/255, alpha: 1.0) // 16
    static let BallColor5 = SKColor(red: 223/255, green:139/255, blue: 136/255, alpha: 1.0) // 32
    static let BallColor6 = SKColor(red: 157/255, green:116/255, blue: 165/255, alpha: 1.0) // 64
    static let BallColor7 = SKColor(red: 142/255, green:205/255, blue: 204/255, alpha: 1.0) // 128
    static let BallColor8 = SKColor(red: 255/255, green:159/255, blue: 45/255, alpha: 1.0) // 256
    static let BallColor9 = SKColor(red: 106/255, green:130/255, blue: 181/255, alpha: 1.0) // 512
    static let BallColor10 = SKColor(red: 148/255, green:163/255, blue: 179/255, alpha: 1.0) // 1024
    static let BallColorMax = SKColor(red: 74/255, green:78/255, blue: 108/255, alpha: 1.0) // 2048
    
    // Block Colors - Night
    static let BlockColor1_Night = SKColor(red: 232/255, green:59/255, blue: 73/255, alpha: 1.0) // red
    static let BlockColor2_Night = SKColor(red: 25/255, green:127/255, blue: 167/255, alpha: 1.0) // blue
    static let BlockColor3_Night = SKColor(red: 250/255, green:198/255, blue: 86/255, alpha: 1.0)  // yellow
    static let BlockColor4_Night = SKColor(red: 42/255, green:166/255, blue: 98/255, alpha: 1.0) // green
    static let BlockColor5_Night = SKColor(red: 124/255, green:98/255, blue: 82/255, alpha: 1.0) // brown
    static let BlockColor6_Night = SKColor(red: 225/255, green:70/255, blue: 140/255, alpha: 1.0) // pink
    static let BlockColor7_Night = SKColor(red: 69/255, green:199/255, blue: 185/255, alpha: 1.0) // teal
    static let BlockColor8_Night = SKColor(red: 128/255, green:88/255, blue: 182/255, alpha: 1.0) // purple
    static let BlockColor9_Night = SKColor(red: 255/255, green:153/255, blue: 112/255, alpha: 1.0) // orange
    
    
    static func getBackgroundColor() -> SKColor {
        if UserDefaults.standard.object(forKey: "mode") == nil {
            UserDefaults.standard.set("Dark", forKey: "mode")
        }
        let selectedMode = UserDefaults.standard.object(forKey: "mode") as! String
        
        if selectedMode == "Bright" {
            return BackgroundColor_Bright
        } else if selectedMode == "Dark" {
            return BackgroundColor_Dark
        } else {
            return SKColor.clear
        }
    }
    
    static func getBallColor(index: Int) -> SKColor {
        switch index {
        case 1:
            return BallColor1
        case 2:
            return BallColor2
        case 3:
            return BallColor3
        case 4:
            return BallColor4
        case 5:
            return BallColor5
        case 6:
            return BallColor6
        case 7:
            return BallColor7
        case 8:
            return BallColor8
        case 9:
            return BallColor9
        case 10:
            return BallColor10
        default:
            return BallColorMax
        }
    }
    
    
    static func getTopBarColor() -> SKColor {
        let selectedMode = UserDefaults.standard.object(forKey: "mode") as! String
        
        if selectedMode == "Bright" {
            return TopBarColor_Bright
        } else if selectedMode == "Dark" {
            return TopBarColor_Dark
        } else {
            return SKColor.clear
        }
    }
    
    static func getCellBackgroundColor() -> SKColor {
        let selectedMode = UserDefaults.standard.object(forKey: "mode") as! String
        
        if selectedMode == "Bright" {
            return CellBackgroundColor_Bright
        } else if selectedMode == "Dark" {
            return CellBackgroundColor_Dark
        } else {
            return SKColor.clear
        }
    }
    
    static func getLineColor() -> SKColor {
        let selectedMode = UserDefaults.standard.object(forKey: "mode") as! String
        
        if selectedMode == "Bright" {
            return LineColor_Bright
        } else if selectedMode == "Dark" {
            return LineColor_Dark
        } else {
            return SKColor.clear
        }
    }
    
    static func getMessageFontColor() -> SKColor {
        let selectedMode = UserDefaults.standard.object(forKey: "mode") as! String
        
        if selectedMode == "Bright" {
            return MessageFontColor_Bright
        } else if selectedMode == "Dark" {
            return MessageFontColor_Dark
        } else {
            return SKColor.clear
        }
    }
    
    static func getTextFontColor() -> SKColor {
        let selectedMode = UserDefaults.standard.object(forKey: "mode") as! String
        
        if selectedMode == "Bright" {
            return TextFontColor_Bright
        } else if selectedMode == "Dark" {
            return TextFontColor_Dark
        } else {
            return SKColor.clear
        }
    }
    
    static func getControlButtonColor() -> SKColor {
        let selectedMode = UserDefaults.standard.object(forKey: "mode") as! String
        
        if selectedMode == "Bright" {
            return ControlButtonColor_Bright
        } else if selectedMode == "Dark" {
            return ControlButtonColor_Dark
        } else {
            return SKColor.clear
        }
    }
}


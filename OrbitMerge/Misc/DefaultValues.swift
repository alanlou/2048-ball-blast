//
//  DefaultValues.swift
//  OrbitMerge
//
//  Created by Alan Lou on 7/12/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import SpriteKit

struct ColorCategory {
    // Background Colors
    static let BackgroundColor_Simple = SKColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
    static let BackgroundColor_Modern = SKColor(red: 241/255, green: 242/255, blue:246/255, alpha: 1.0)
    static let BackgroundColor_Warm = SKColor(red: 246/255, green: 238/255, blue:233/255, alpha: 1.0)
    static let BackgroundColor_Bright = SKColor(red: 254/255, green: 254/255, blue:254/255, alpha: 1.0)
    static let BackgroundColor_Dark = SKColor(red: 37/255, green: 37/255, blue:37/255, alpha: 1.0)
    static let BackgroundColor_Mint = SKColor(red: 73/255, green: 87/255, blue:101/255, alpha: 1.0)
    
    // Bar Top Colors
    static var BarTopColor_Simple = SKColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1.0)
    static let BarTopColor_Modern = SKColor(red: 119/255, green: 126/255, blue: 140/255, alpha: 1.0)
    static let BarTopColor_Warm = SKColor(red: 217/255, green: 146/255, blue: 128/255, alpha: 1.0)
    static let BarTopColor_Bright = SKColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1.0)
    static let BarTopColor_Dark = SKColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1.0)
    static let BarTopColor_Mint = SKColor(red: 103/255, green: 185/255, blue: 146/255, alpha: 1.0)
    
    // Bar Bottom Colors
    static var BarBottomColor_Simple = SKColor(red: 194/255, green: 194/255, blue: 194/255, alpha: 1.0)
    static let BarBottomColor_Modern = SKColor(red: 73/255, green: 72/255, blue: 101/255, alpha: 1.0)
    static let BarBottomColor_Warm = SKColor(red: 163/255, green: 110/255, blue: 99/255, alpha: 1.0)
    static let BarBottomColor_Bright = SKColor(red: 194/255, green: 194/255, blue: 194/255, alpha: 1.0)
    static let BarBottomColor_Dark = SKColor(red: 194/255, green: 194/255, blue: 194/255, alpha: 1.0)
    static let BarBottomColor_Mint = SKColor(red: 71/255, green: 127/255, blue: 104/255, alpha: 1.0)
    
    // Icon Colors
    static var MenuIconColor_Simple = SKColor(red: 123/255, green: 133/255, blue: 156/255, alpha: 1.0)
    static let MenuIconColor_Modern = SKColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
    static let MenuIconColor_Warm = SKColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
    static let MenuIconColor_Bright = SKColor(red: 123/255, green: 133/255, blue: 156/255, alpha: 1.0)
    static let MenuIconColor_Dark = SKColor(red: 123/255, green: 133/255, blue: 156/255, alpha: 1.0)
    static let MenuIconColor_Mint = SKColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
    
    // Text Colors
    static var TextFontColor_Simple = SKColor(red: 123/255, green: 133/255, blue: 156/255, alpha: 1.0)
    static var TextFontColor_Modern = SKColor(red: 123/255, green: 133/255, blue: 156/255, alpha: 1.0)
    static var TextFontColor_Warm = SKColor(red: 123/255, green: 133/255, blue: 156/255, alpha: 1.0)
    static var TextFontColor_Bright = SKColor(red: 123/255, green: 133/255, blue: 156/255, alpha: 1.0)
    static var TextFontColor_Dark = SKColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
    static var TextFontColor_Mint = SKColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
    
    // Start Button Colors
    static var StartButtonColor_Simple = SKColor(red: 238/255, green: 112/255, blue: 124/255, alpha: 1.0)
    static var StartButtonColor_Modern = SKColor(red: 238/255, green: 112/255, blue: 124/255, alpha: 1.0)
    static var StartButtonColor_Warm = SKColor(red: 238/255, green: 112/255, blue: 124/255, alpha: 1.0)
    static var StartButtonColor_Bright = SKColor(red: 238/255, green: 112/255, blue: 124/255, alpha: 1.0)
    static var StartButtonColor_Dark = SKColor(red: 238/255, green: 112/255, blue: 124/255, alpha: 1.0)
    static var StartButtonColor_Mint = SKColor(red: 238/255, green: 112/255, blue: 124/255, alpha: 1.0)
    
    // Start Button Shadow Colors
    static var StartButtonShadowColor_Simple = SKColor(red: 180/255, green: 80/255, blue: 94/255, alpha: 1.0)
    static var StartButtonShadowColor_Modern = SKColor(red: 172/255, green: 77/255, blue: 90/255, alpha: 1.0)
    static var StartButtonShadowColor_Warm = SKColor(red: 172/255, green: 77/255, blue: 90/255, alpha: 1.0)
    static var StartButtonShadowColor_Bright = SKColor(red: 172/255, green: 77/255, blue: 90/255, alpha: 1.0)
    static var StartButtonShadowColor_Dark = SKColor(red: 172/255, green: 77/255, blue: 90/255, alpha: 1.0)
    static var StartButtonShadowColor_Mint = SKColor(red: 172/255, green: 77/255, blue: 90/255, alpha: 1.0)
    
    // Ball Colors - Simple
    static let BallColor1_Simple = SKColor(red: 251/255, green: 196/255, blue: 75/255, alpha: 1.0) // 2
    static let BallColor2_Simple = SKColor(red: 122/255, green: 175/255, blue: 163/255, alpha: 1.0) // 4
    static let BallColor3_Simple = SKColor(red: 250/255, green: 112/255, blue: 129/255, alpha: 1.0) // 8
    static let BallColor4_Simple = SKColor(red: 76/255, green: 156/255, blue: 186/255, alpha: 1.0) // 16
    static let BallColor5_Simple = SKColor(red: 230/255, green: 139/255, blue: 138/255, alpha: 1.0) // 32
    static let BallColor6_Simple = SKColor(red: 160/255, green: 116/255, blue: 163/255, alpha: 1.0) // 64
    static let BallColor7_Simple = SKColor(red: 133/255, green: 205/255, blue: 203/255, alpha: 1.0) // 128
    static let BallColor8_Simple = SKColor(red: 255/255, green: 159/255, blue: 64/255, alpha: 1.0) // 256
    static let BallColor9_Simple = SKColor(red: 102/255, green: 130/255, blue: 179/255, alpha: 1.0) // 512
    static let BallColor10_Simple = SKColor(red: 146/255, green: 163/255, blue: 178/255, alpha: 1.0) // 1024
    static let BallColorMax_Simple = SKColor(red: 73/255, green: 78/255, blue: 107/255, alpha: 1.0) // 2048
    
    // Ball Colors - Modern
    static let BallColor1_Modern = SKColor(red: 245/255, green: 201/255, blue: 84/255, alpha: 1.0) // 2
    static let BallColor2_Modern = SKColor(red: 149/255, green: 200/255, blue: 96/255, alpha: 1.0) // 4
    static let BallColor3_Modern = SKColor(red: 233/255, green: 83/255, blue: 97/255, alpha: 1.0) // 8
    static let BallColor4_Modern = SKColor(red: 94/255, green: 156/255, blue: 234/255, alpha: 1.0) // 16
    static let BallColor5_Modern = SKColor(red: 227/255, green: 182/255, blue: 146/255, alpha: 1.0) // 32
    static let BallColor6_Modern = SKColor(red: 172/255, green: 146/255, blue: 235/255, alpha: 1.0) // 64
    static let BallColor7_Modern = SKColor(red: 70/255, green: 207/255, blue: 172/255, alpha: 1.0) // 128
    static let BallColor8_Modern = SKColor(red: 246/255, green: 108/255, blue: 81/255, alpha: 1.0) // 256
    static let BallColor9_Modern = SKColor(red: 235/255, green: 134/255, blue: 191/255, alpha: 1.0) // 512
    static let BallColor10_Modern = SKColor(red: 169/255, green: 176/255, blue: 187/255, alpha: 1.0) // 1024
    static let BallColorMax_Modern = SKColor(red: 66/255, green: 72/255, blue: 81/255, alpha: 1.0) // 2048
    
    // Ball Colors - Bright
    static let BallColor1_Bright = SKColor(red: 251/255, green: 210/255, blue: 119/255, alpha: 1.0) // 2
    static let BallColor2_Bright = SKColor(red: 182/255, green: 217/255, blue: 86/255, alpha: 1.0) // 4
    static let BallColor3_Bright = SKColor(red: 246/255, green: 108/255, blue: 130/255, alpha: 1.0) // 8
    static let BallColor4_Bright = SKColor(red: 139/255, green: 211/255, blue: 255/255, alpha: 1.0) // 16
    static let BallColor5_Bright = SKColor(red: 217/255, green: 152/255, blue: 203/255, alpha: 1.0) // 32
    static let BallColor6_Bright = SKColor(red: 247/255, green: 131/255, blue: 111/255, alpha: 1.0) // 64
    static let BallColor7_Bright = SKColor(red: 92/255, green: 186/255, blue: 229/255, alpha: 1.0) // 128
    static let BallColor8_Bright = SKColor(red: 227/255, green: 182/255, blue: 146/255, alpha: 1.0) // 256
    static let BallColor9_Bright = SKColor(red: 152/255, green: 170/255, blue: 251/255, alpha: 1.0) // 512
    static let BallColor10_Bright = SKColor(red: 159/255, green: 166/255, blue: 177/255, alpha: 1.0) // 1024
    static let BallColorMax_Bright = SKColor(red: 97/255, green: 124/255, blue: 171/255, alpha: 1.0) // 2048
    
    // Ball Colors - Dark
    static let BallColor1_Dark  = SKColor(red: 227/255, green: 150/255, blue: 0/255, alpha: 1.0) // 2
    static let BallColor2_Dark  = SKColor(red: 32/255, green: 146/255, blue: 80/255, alpha: 1.0) // 4
    static let BallColor3_Dark  = SKColor(red: 200/255, green: 46/255, blue: 46/255, alpha: 1.0) // 8
    static let BallColor4_Dark  = SKColor(red: 40/255, green: 127/255, blue: 184/255, alpha: 1.0) // 16
    static let BallColor5_Dark  = SKColor(red: 195/255, green: 78/255, blue: 1/255, alpha: 1.0) // 32
    static let BallColor6_Dark  = SKColor(red: 127/255, green: 157/255, blue: 28/255, alpha: 1.0) // 64
    static let BallColor7_Dark  = SKColor(red: 56/255, green: 159/255, blue: 168/255, alpha: 1.0) // 128
    static let BallColor8_Dark  = SKColor(red: 26/255, green: 100/255, blue: 111/255, alpha: 1.0) // 256
    static let BallColor9_Dark  = SKColor(red: 52/255, green: 72/255, blue: 80/255, alpha: 1.0) // 512
    static let BallColor10_Dark  = SKColor(red: 101/255, green: 65/255, blue: 139/255, alpha: 1.0) // 1024
    static let BallColorMax_Dark  = SKColor(red: 34/255, green: 54/255, blue: 76/255, alpha: 1.0) // 2048
    
    // Ball Colors - Mint
    static let BallColor1_Mint  = SKColor(red: 250/255, green: 192/255, blue: 75/255, alpha: 1.0) // 2
    static let BallColor2_Mint  = SKColor(red: 17/255, green: 187/255, blue: 117/255, alpha: 1.0) // 4
    static let BallColor3_Mint  = SKColor(red: 238/255, green: 82/255, blue: 122/255, alpha: 1.0) // 8
    static let BallColor4_Mint  = SKColor(red: 74/255, green: 136/255, blue: 218/255, alpha: 1.0) // 16
    static let BallColor5_Mint  = SKColor(red: 234/255, green: 172/255, blue: 152/255, alpha: 1.0) // 32
    static let BallColor6_Mint  = SKColor(red: 108/255, green: 99/255, blue: 200/255, alpha: 1.0) // 64
    static let BallColor7_Mint  = SKColor(red: 130/255, green: 44/255, blue: 102/255, alpha: 1.0) // 128
    static let BallColor8_Mint  = SKColor(red: 219/255, green: 110/255, blue: 75/255, alpha: 1.0) // 256
    static let BallColor9_Mint  = SKColor(red: 27/255, green: 85/255, blue: 202/255, alpha: 1.0) // 512
    static let BallColor10_Mint  = SKColor(red: 130/255, green: 57/255, blue: 57/255, alpha: 1.0) // 1024
    static let BallColorMax_Mint  = SKColor(red: 30/255, green: 45/255, blue: 90/255, alpha: 1.0) // 2048
    
    static func getBallColor(index: Int, mode selectedMode: String) -> SKColor {
        if (selectedMode == "Simple" || selectedMode == "Warm") {
            switch index {
            case 1:
                return BallColor1_Simple
            case 2:
                return BallColor2_Simple
            case 3:
                return BallColor3_Simple
            case 4:
                return BallColor4_Simple
            case 5:
                return BallColor5_Simple
            case 6:
                return BallColor6_Simple
            case 7:
                return BallColor7_Simple
            case 8:
                return BallColor8_Simple
            case 9:
                return BallColor9_Simple
            case 10:
                return BallColor10_Simple
            default:
                return BallColorMax_Simple
            }
        } else if (selectedMode == "Modern"){
            switch index {
            case 1:
                return BallColor1_Modern
            case 2:
                return BallColor2_Modern
            case 3:
                return BallColor3_Modern
            case 4:
                return BallColor4_Modern
            case 5:
                return BallColor5_Modern
            case 6:
                return BallColor6_Modern
            case 7:
                return BallColor7_Modern
            case 8:
                return BallColor8_Modern
            case 9:
                return BallColor9_Modern
            case 10:
                return BallColor10_Modern
            default:
                return BallColorMax_Modern
            }
        } else if (selectedMode == "Bright"){
            switch index {
            case 1:
                return BallColor1_Bright
            case 2:
                return BallColor2_Bright
            case 3:
                return BallColor3_Bright
            case 4:
                return BallColor4_Bright
            case 5:
                return BallColor5_Bright
            case 6:
                return BallColor6_Bright
            case 7:
                return BallColor7_Bright
            case 8:
                return BallColor8_Bright
            case 9:
                return BallColor9_Bright
            case 10:
                return BallColor10_Bright
            default:
                return BallColorMax_Bright
            }
        } else if (selectedMode == "Dark"){
            switch index {
            case 1:
                return BallColor1_Dark
            case 2:
                return BallColor2_Dark
            case 3:
                return BallColor3_Dark
            case 4:
                return BallColor4_Dark
            case 5:
                return BallColor5_Dark
            case 6:
                return BallColor6_Dark
            case 7:
                return BallColor7_Dark
            case 8:
                return BallColor8_Dark
            case 9:
                return BallColor9_Dark
            case 10:
                return BallColor10_Dark
            default:
                return BallColorMax_Dark
            }
        } else if (selectedMode == "Mint"){
            switch index {
            case 1:
                return BallColor1_Mint
            case 2:
                return BallColor2_Mint
            case 3:
                return BallColor3_Mint
            case 4:
                return BallColor4_Mint
            case 5:
                return BallColor5_Mint
            case 6:
                return BallColor6_Mint
            case 7:
                return BallColor7_Mint
            case 8:
                return BallColor8_Mint
            case 9:
                return BallColor9_Mint
            case 10:
                return BallColor10_Mint
            default:
                return BallColorMax_Mint
            }
        } else {
            return SKColor.clear
        }
    }
    
    static func getBallColor(index: Int) -> SKColor {
        let selectedMode = getSelectedMode()
        return getBallColor(index: index, mode: selectedMode)
    }
    
    static func getBackgroundColor(mode selectedMode: String) -> SKColor {
        if selectedMode == "Simple" {
            return BackgroundColor_Simple
        } else if selectedMode == "Dark" {
            return BackgroundColor_Dark
        } else if selectedMode == "Modern" {
            return BackgroundColor_Modern
        } else if selectedMode == "Warm" {
            return BackgroundColor_Warm
        } else if selectedMode == "Bright" {
            return BackgroundColor_Bright
        } else if selectedMode == "Mint" {
            return BackgroundColor_Mint
        } else {
            return SKColor.clear
        }
    }
    
    static func getBackgroundColor() -> SKColor {
        let selectedMode = getSelectedMode()
        return getBackgroundColor(mode: selectedMode)
    }
    
    static func getBarTopColor(mode selectedMode: String) -> SKColor {
        if selectedMode == "Simple" {
            return BarTopColor_Simple
        } else if selectedMode == "Dark" {
            return BarTopColor_Dark
        } else if selectedMode == "Modern" {
            return BarTopColor_Modern
        } else if selectedMode == "Warm" {
            return BarTopColor_Warm
        } else if selectedMode == "Bright" {
            return BarTopColor_Bright
        } else if selectedMode == "Mint" {
            return BarTopColor_Mint
        } else {
            return SKColor.clear
        }
    }
    
    static func getBarTopColor() -> SKColor {
        let selectedMode = getSelectedMode()
        return getBarTopColor(mode: selectedMode)
    }
    
    static func getBarBottomColor(mode selectedMode: String) -> SKColor {
        if selectedMode == "Simple" {
            return BarBottomColor_Simple
        } else if selectedMode == "Dark" {
            return BarBottomColor_Dark
        } else if selectedMode == "Modern" {
            return BarBottomColor_Modern
        } else if selectedMode == "Warm" {
            return BarBottomColor_Warm
        } else if selectedMode == "Bright" {
            return BarBottomColor_Bright
        } else if selectedMode == "Mint" {
            return BarBottomColor_Mint
        } else {
            return SKColor.clear
        }
    }
    
    static func getBarBottomColor() -> SKColor {
        let selectedMode = getSelectedMode()
        return getBarBottomColor(mode: selectedMode)
    }
    
    static func getLineColor() -> SKColor {
        return getBarBottomColor()
    }
    
    static func getTextFontColor(mode selectedMode: String) -> SKColor {
        if selectedMode == "Simple" {
            return TextFontColor_Simple
        } else if selectedMode == "Dark" {
            return TextFontColor_Dark
        } else if selectedMode == "Modern" {
            return TextFontColor_Modern
        } else if selectedMode == "Warm" {
            return TextFontColor_Warm
        } else if selectedMode == "Bright" {
            return TextFontColor_Bright
        } else if selectedMode == "Mint" {
            return TextFontColor_Mint
        } else {
            return SKColor.clear
        }
    }
    
    static func getTextFontColor() -> SKColor {
        let selectedMode = getSelectedMode()
        return getTextFontColor(mode: selectedMode)
    }
    
    static func getStartButtonColor() -> SKColor {
        let selectedMode = getSelectedMode()
        
        if selectedMode == "Simple" {
            return StartButtonColor_Simple
        } else if selectedMode == "Dark" {
            return StartButtonColor_Dark
        } else if selectedMode == "Modern" {
            return StartButtonColor_Modern
        } else if selectedMode == "Warm" {
            return StartButtonColor_Warm
        } else if selectedMode == "Bright" {
            return StartButtonColor_Bright
        } else if selectedMode == "Mint" {
            return StartButtonColor_Mint
        } else {
            return SKColor.clear
        }
    }
    
    static func getStartButtonShadowColor() -> SKColor {
        let selectedMode = getSelectedMode()
        
        if selectedMode == "Simple" {
            return StartButtonShadowColor_Simple
        } else if selectedMode == "Dark" {
            return StartButtonShadowColor_Dark
        } else if selectedMode == "Modern" {
            return StartButtonShadowColor_Modern
        } else if selectedMode == "Warm" {
            return StartButtonShadowColor_Warm
        } else if selectedMode == "Bright" {
            return StartButtonShadowColor_Bright
        } else if selectedMode == "Mint" {
            return StartButtonShadowColor_Mint
        } else {
            return SKColor.clear
        }
    }
    
    static func getMenuIconColor(mode selectedMode: String) -> SKColor {
        if selectedMode == "Simple" {
            return MenuIconColor_Simple
        } else if selectedMode == "Dark" {
            return MenuIconColor_Dark
        } else if selectedMode == "Modern" {
            return MenuIconColor_Modern
        } else if selectedMode == "Warm" {
            return MenuIconColor_Warm
        } else if selectedMode == "Bright" {
            return MenuIconColor_Bright
        } else if selectedMode == "Mint" {
            return MenuIconColor_Mint
        } else {
            return SKColor.clear
        }
    }
    
    static func getMenuIconColor() -> SKColor {
        let selectedMode = getSelectedMode()
        return getMenuIconColor(mode: selectedMode)
    }
    
    static func getSelectedMode() -> String {
        let decoded  = UserDefaults.standard.object(forKey: "SelectedMode") as! Data
        let currentSelectedMode = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! ModeItem
        return currentSelectedMode.identifier
    }
}


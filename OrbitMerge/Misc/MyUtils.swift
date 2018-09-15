//
//  MyUtils.swift
//  BreakoutDraw
//
//  Created by Alan Lou on 7/12/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

public extension Int {
    /// returns number of digits in Int number
    public var digitCount: Int {
        get {
            return numberOfDigits(in: self)
        }
    }
    // private recursive method for counting digits
    private func numberOfDigits(in number: Int) -> Int {
        if abs(number) < 10 {
            return 1
        } else {
            return 1 + numberOfDigits(in: number/10)
        }
    }
}

extension CGFloat {
    func sign() -> CGFloat {
        return self >= 0.0 ? 1.0 : -1.0
    }
    
    static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UInt32.max))
    }
    
    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        assert(min < max)
        return CGFloat.random() * (max - min) + min
    }
    
    var smallRotationAngle: CGFloat {
        var adjRotationAngle = self.truncatingRemainder(dividingBy: 2.0*CGFloat.pi)
        if adjRotationAngle < 0 {
            adjRotationAngle = adjRotationAngle+CGFloat.pi*2.0
        }
        return adjRotationAngle
    }
}

extension UIView {
    func pb_takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

extension SKNode {
    var rotationAngle:CGFloat {
        return self.zRotation.truncatingRemainder(dividingBy: 2.0*CGFloat.pi)
    }
}

extension SKSpriteNode {
    
    func addGlow(radius: CGFloat = 30) {
        let effectNode = SKEffectNode()
        effectNode.shouldRasterize = true
        addChild(effectNode)
        effectNode.addChild(SKSpriteNode(texture: texture))
        effectNode.filter = CIFilter(name: "CIGaussianBlur", withInputParameters: ["inputRadius":radius])
    }
}

extension Array {
    mutating func remove(at indexs: [Int]) {
        guard !isEmpty else { return }
        let newIndexs = Set(indexs).sorted(by: >)
        newIndexs.forEach {
            guard $0 < count, $0 >= 0 else { return }
            remove(at: $0)
        }
    }
    
    func copiedElements() -> Array<Element> {
        return self.map{
            let copiable = $0 as! NSCopying
            return copiable.copy() as! Element
        }
    }
}

extension CGVector {
    var magnitude:CGFloat {
        return sqrt(self.dx*self.dx+self.dy*self.dy)
    }
    var yMagnitude:CGFloat {
        return sqrt(self.dy*self.dy)
    }
}

extension UITouch
{
    var positionOnScene : CGPoint
    {
        return self.location(in: (self.view as! SKView).scene!)
    }
}

extension CGPoint
{
    static public func +(lhs:CGPoint,rhs:CGPoint) -> CGPoint
    {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    static public func -(lhs:CGPoint,rhs:CGPoint) -> CGPoint
    {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    static public func -= (lhs:inout CGPoint,rhs:CGPoint)
    {
        lhs = lhs - rhs
    }
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

protocol Alertable { }
extension Alertable where Self: SKScene {
    
    func showAlert(withTitle title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel) { _ in }
        alertController.addAction(okAction)
        
        UIApplication.topViewController()?.present(alertController, animated: true)
    }
}


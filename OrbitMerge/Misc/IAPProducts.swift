//
//  IAPProducts.swift
//  Squares
//
//  Created by Alan Lou on 6/28/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

import Foundation

public struct IAPProducts {
    
    public static let NoAds = "com.RawwrStudios.BallvsCup.RemoveGameAds"
    public static let Ring200 = "com.RawwrStudios.BallvsCup.AddRings200"
    public static let Ring500 = "com.RawwrStudios.BallvsCup.AddRings500"
    public static let Ring900 = "com.RawwrStudios.BallvsCup.AddRings900"
    
    fileprivate static let productIdentifiers: Set<ProductIdentifier> = [IAPProducts.NoAds, IAPProducts.Ring200, IAPProducts.Ring500, IAPProducts.Ring900]
    
    public static let store = IAPHelper(productIds: IAPProducts.productIdentifiers)
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}

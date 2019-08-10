//
//  RandomWallGeneration.swift
//  Flappy Ghost
//
//  Created by KHH on 10/8/2019.
//  Copyright © 2019 Kwan Hiu Hong. All rights reserved.
//

import Foundation
import CoreGraphics

public extension CGFloat{
    
    public static func random() -> CGFloat {
        //arc4random will create a random number/integer, with UInt32 type
        //0xFFFFFFFF is simply 2^32 - 1
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    //this function create random number that is within certain range
    public static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random() * (max - min) + min
    }
    
}

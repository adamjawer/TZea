//
//  UIColor+Extensions.swift
//  Punchbowl
//
//  Created by Adam Jawer on 9/21/16.
//  Copyright © 2016 Adam Jawer. All rights reserved.
//

import UIKit

extension UIColor {
    
    class func colorWithRGB(r: Float, g: Float, b: Float) -> UIColor {
        return UIColor(red: CGFloat(Float(r / 255)), green: CGFloat(g / 255.0), blue: CGFloat(b / 255.0), alpha: 1)
    }

    class func colorWithRGB(r: Float, g: Float, b: Float, alpha: CGFloat) -> UIColor {
        return UIColor(red: CGFloat(Float(r / 255)), green: CGFloat(g / 255.0), blue: CGFloat(b / 255.0), alpha: alpha)
    }

    class func colorWith(hexCode hex: Int) -> UIColor {
        let r = (hex >> 16) & 0xff
        let g = (hex >> 8) & 0xff
        let b = hex & 0xff
        
        return UIColor.colorWithRGB(r: Float(r), g: Float(g), b: Float(b))
    }

    class func colorWith(hexCode hex: Int, alpha: CGFloat) -> UIColor {
        let r = (hex >> 16) & 0xff
        let g = (hex >> 8) & 0xff
        let b = hex & 0xff
        
        return UIColor.colorWithRGB(r: Float(r), g: Float(g), b: Float(b), alpha: alpha)
    }

    
    class func defaultStatus() -> UIColor {
        return UIColor.colorWith(hexCode: 0x14171a)
    }
    
    class func screenName() -> UIColor {
        return UIColor.colorWith(hexCode: 0x657786)
    }
    
    class func inlineHighlight() -> UIColor {
        return UIColor.colorWith(hexCode: 0x1b95e0)
    }
    
}

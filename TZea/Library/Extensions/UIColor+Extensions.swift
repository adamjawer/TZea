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
}

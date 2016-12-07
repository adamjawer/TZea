//
//  GradientView.swift
//  Punchbowl
//
//  Created by Adam Jawer on 9/21/16.
//  Copyright © 2016 Adam Jawer. All rights reserved.
//

import UIKit

class GradientView: UIView {
    var gradientLayer : CAGradientLayer?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        gradientLayer = CAGradientLayer()
        
        let color1 = UIColor.colorWithRGB(r: 231, g: 162, b: 226).cgColor
        let color2 = UIColor.colorWithRGB(r: 93, g: 40, b: 107).cgColor
        
        gradientLayer?.colors = [color1, color2]
        gradientLayer?.startPoint = CGPoint.zero
        gradientLayer?.endPoint = CGPoint(x: 1, y: 1)
        
        layer.addSublayer(gradientLayer!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer?.frame = bounds
    }
    
}

//
//  ComposeToolbar.swift
//  TZea
//
//  Created by Adam Jawer on 12/7/16.
//  Copyright © 2016 Adam Jawer. All rights reserved.
//

import UIKit

class ComposeToolbar: UIView {

    @IBOutlet weak var charactersRemainingLabel: UILabel!
    @IBOutlet weak var tweetButton: UIButton!
    
    var didPressSend: ((_ sender: ComposeToolbar)->())!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tweetButton.layer.cornerRadius = 6
        tweetButton.layer.borderWidth = 1
        setTweetButton(enabled: false)
    }
    
    func setTweetButton(enabled: Bool) {
        tweetButton.isEnabled = enabled
        
        let color: UIColor = enabled ? UIColor.colorWithRGB(r: 102, g: 102, b: 102) : UIColor.colorWithRGB(r: 175, g: 175, b: 175)
        
        tweetButton.layer.borderColor = color.cgColor
        tweetButton.setTitleColor(color, for: .normal)
    }

    @IBAction func tweetButtonPressed(_ sender: UIButton) {
        didPressSend(self)
    }
}

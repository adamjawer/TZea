//
//  ComposeViewController.swift
//  TZea
//
//  Created by Adam Jawer on 12/7/16.
//  Copyright © 2016 Adam Jawer. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    var composeToolbar: ComposeToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        composeToolbar = Bundle.main.loadNibNamed("ComposeToolbar", owner: nil, options: nil)?.first as! ComposeToolbar!
        textView.inputAccessoryView = composeToolbar
        composeToolbar.setTweetButton(enabled: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textView.becomeFirstResponder()
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}

extension ComposeViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let count = (textView.text?.characters.count ?? 0) + text.characters.count - range.length
        print(count)
        composeToolbar.setTweetButton(enabled: count > 0)        
        
        if count <= 140 {
            composeToolbar.charactersRemainingLabel.text = String(140 - count)
            return true
        } else {
            return false
        }
    }
}

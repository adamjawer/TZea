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
    @IBOutlet weak var promptLabel: UILabel!
    
    var composeToolbar: ComposeToolbar!
    
    var didClose:((Bool)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        composeToolbar = Bundle.main.loadNibNamed("ComposeToolbar", owner: nil, options: nil)?.first as! ComposeToolbar!
        composeToolbar.didPressSend = { (_) in
            self.postPressed()
        }
        
        textView.inputAccessoryView = composeToolbar
        composeToolbar.setTweetButton(enabled: false)
        promptLabel.text = "What's on your mind?"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textView.becomeFirstResponder()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func statusText() -> String {
        return textView.text
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        if let didClose = self.didClose {
            self.textView.resignFirstResponder()
            didClose(false)
        }
    }
    
    func postPressed() {
        // attempt to POST the tweet
        TwitterHelper.sharedInstance().post(statusText: statusText()) { (json, error) in
            
            guard error == nil, json != nil else {
                let alertController = UIAlertController(title: "Error posting tweet",
                                                        message: "\(error?.localizedDescription) ?? nil",
                                                        preferredStyle: .alert)
                self.present(alertController, animated: true)
                return
            }
        
            self.textView.resignFirstResponder()
            
            if let didClose = self.didClose {
                didClose(true)
            }
        }
    }

}

extension ComposeViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let count = (textView.text?.characters.count ?? 0) + text.characters.count - range.length
        
        composeToolbar.setTweetButton(enabled: count > 0)
        
        if count <= 140 {
            composeToolbar.charactersRemainingLabel.text = String(140 - count)
            return true
        } else {
            return false
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let count = textView.text?.characters.count ?? 0
        promptLabel.alpha = (count == 0) ? 1 : 0
    }
}

//
//  TZTweet.swift
//  TZea
//
//  Created by Adam Jawer on 12/7/16.
//  Copyright © 2016 Adam Jawer. All rights reserved.
//

import Foundation
import SwiftyJSON

struct TZTweet {
    var json: Dictionary<String, Any>
    
    init(withJson: Dictionary<String, Any>) {
        json = withJson
    }
    
    func userName() -> String? {
       return ""
    }
}

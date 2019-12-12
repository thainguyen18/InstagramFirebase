//
//  Comment.swift
//  InstagramFirebase
//
//  Created by Thai Nguyen on 12/12/19.
//  Copyright © 2019 Thai Nguyen. All rights reserved.
//

import Foundation

struct Comment {
    let text: String
    let uid: String
    
    let user: User
    
    init(user: User, dictionary: [String : Any]) {
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["userId"] as? String ?? ""
        self.user = user
    }
}

//
//  User.swift
//  InstagramFirebase
//
//  Created by Thai Nguyen on 12/8/19.
//  Copyright © 2019 Thai Nguyen. All rights reserved.
//

import Foundation

class User {
    let username: String
    let profileImageUrl: String
    let uid: String
    let numberOfPosts: Int
    
    init(uid: String, dictionary: [String:Any]) {
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.uid = uid
        self.numberOfPosts = dictionary["numberOfPosts"] as? Int ?? 0
    }
}

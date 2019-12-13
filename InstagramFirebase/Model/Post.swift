//
//  Post.swift
//  InstagramFirebase
//
//  Created by Thai Nguyen on 12/7/19.
//  Copyright © 2019 Thai Nguyen. All rights reserved.
//

import Foundation

struct Post {
    let imageUrl: String
    let caption: String
    let creationDate: Double
    let imageWidth: Double
    let imageHeight: Double
    let user: User
    
    var id: String?
    
    var hasLiked: Bool = false
    
    init(user: User, dictionary: [String: Any]) {
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.caption = dictionary["caption"] as? String ?? ""
        self.creationDate = dictionary["creationDate"] as? Double ?? 0
        self.imageWidth = dictionary["imageWidth"] as? Double ?? 0
        self.imageHeight = dictionary["imageHeight"] as? Double ?? 0
        self.user = user
    }
}

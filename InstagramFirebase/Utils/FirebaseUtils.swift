//
//  FirebaseUtils.swift
//  InstagramFirebase
//
//  Created by Thai Nguyen on 12/9/19.
//  Copyright © 2019 Thai Nguyen. All rights reserved.
//

import Firebase

extension Firestore {
    static func fetchUserWithUID(uid: String, completion: @escaping (User) -> ()) {
        // Fetch user
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, error) in
            if let err = error {
                print("Failed to fetch user: ", err)
                return
            }
            
            guard let documentDict = snapshot?.data() else { return }
            
            let user = User(uid: uid, dictionary: documentDict)
            
            completion(user)
        }
    }
    
    static func fetchPostsWithUID(uid: String, completion: @escaping (([Post]) -> ())) {
        
        var posts = [Post]()
        
        Firestore.firestore().collection("posts").whereField("userId", isEqualTo: uid).order(by: "creationDate", descending: true).getDocuments { (querySnapshot, error) in
            if let err = error {
                print("Failed to fetch posts: ", err)
                return
            }
            
            Firestore.fetchUserWithUID(uid: uid) { (user) in
                querySnapshot?.documents.forEach { document in
                    let postId = document.documentID
                    
                    var post = Post(user: user, dictionary: document.data())
                    post.id = postId
                    
                    // Check if user liked it
                    Firestore.firestore().collection("likes").document(uid).collection("postsLike").document(postId).getDocument { (snapshot, error) in
                        if let document = snapshot, document.exists {
                            post.hasLiked = true
                        }
                        
                        // Check if user ribboned it
                        Firestore.firestore().collection("ribbons").document(uid).collection("postsRibbon").document(postId).getDocument { (snapshot, error) in
                            if let document = snapshot, document.exists {
                                post.hasRibboned = true
                            }
                            
                            posts.append(post)
                        }
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    completion(posts)
                }
            }
        }
    }
}

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
}

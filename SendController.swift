//
//  SendController.swift
//  InstagramFirebase
//
//  Created by Thai Nguyen on 12/22/19.
//  Copyright © 2019 Thai Nguyen. All rights reserved.
//

import UIKit
import LBTATools
import Firebase

class SendController: LBTAListController<UserSearchCell, User>, UICollectionViewDelegateFlowLayout {
    
    // Properties to keep reference to sender and post
    var senderId: String!
    
    var post: Post!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        
        collectionView.alwaysBounceVertical = true
        
        navigationItem.title = "Select a user to send post"
        
        fetchFollowingUsers()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let view = UIView(frame: collectionView.bounds)
        view.setGradientBackground()
        
        collectionView.backgroundView = view
        
    }
    
    fileprivate func fetchFollowingUsers() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("following").document(currentUserId).collection("follows").getDocuments { (querySnapshot, error) in
            if let err = error {
                print("Failed to fetch following users: ", err)
                return
            }
            
            querySnapshot?.documents.forEach { document in
                let userId = document.documentID
                
                Firestore.fetchUserWithUID(uid: userId) { (user) in
                    
                    self.items.append(user)
                    
                    self.items.sort { $0.username < $1.username }
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.collectionView.reloadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: 60)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let receiver = self.items[indexPath.item]
        
        guard let postId = self.post.id else { return }
        
        let ref = Firestore.firestore().collection("sending").document(currentUserId).collection("sends").document(receiver.uid).collection("sendPosts").document(postId)
        
        ref.getDocument { (snapshot, error) in
            if let err = error {
                print("Failed to read databse: ", err)
                
                return
            }
            
            guard let document = snapshot, !document.exists else {
                print("Already send this post to that user!")
                
                let alert = UIAlertController(title: "Duplicate!", message: "You already sent this post to this user!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                
                return
            }
            
            ref.setData([:]) { (error) in
                if let err = error {
                    print("Failed to send post: ", err)
                    return
                }
                
                DispatchQueue.main.async {
                    let savedLabel = UILabel()
                    savedLabel.text = "Sent successfully"
                    savedLabel.textColor = .white
                    savedLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
                    savedLabel.numberOfLines = 0
                    savedLabel.layer.cornerRadius = 10
                    savedLabel.clipsToBounds = true
                    savedLabel.font = .boldSystemFont(ofSize: 16)
                    savedLabel.textAlignment = .center
                    
                    self.collectionView.addSubview(savedLabel)
                    
                    savedLabel.centerInSuperview()
                    savedLabel.withSize(.init(width: 150, height: 80))
                    
                    
                    savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
                    
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                        savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
                    }) { (completed) in
                        // completed
                        
                        UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                            
                            savedLabel.layer.transform = CATransform3DMakeScale(0.01, 0.01, 0.01)
                            savedLabel.alpha = 0
                            
                        }) { (_) in
                            
                            savedLabel.removeFromSuperview()
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
    }
}


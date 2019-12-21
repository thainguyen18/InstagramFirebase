//
//  LikeController.swift
//  InstagramFirebase
//
//  Created by Thai Nguyen on 12/20/19.
//  Copyright © 2019 Thai Nguyen. All rights reserved.
//

import UIKit
import LBTATools
import Firebase

class LikeController: LBTAListController<HomePostCell, Post>, UICollectionViewDelegateFlowLayout, HomePostCellDelegate {
    
    func didTapComment(post: Post) {
        
    }
    
    func didLike(for cell: HomePostCell) {
        
    }
    
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        
        collectionView.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        
        let refreshControll = UIRefreshControl()
        refreshControll.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControll
        
        fetchLikePosts()
    }
    
    @objc func handleRefresh() {
        
        // Remove old data
        self.items.removeAll()
        
        fetchLikePosts()
    }
    
    
    fileprivate func fetchLikePosts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.fetchUserWithUID(uid: uid) { (user) in
            self.navigationItem.title = user.username
        }
        
        Firestore.firestore().collection("likes").document(uid).collection("postsLike").getDocuments { (snapshot, error) in
            if let err = error {
                print("Failed to fetch posts liked: ", err)
                return
            }
            
            self.collectionView.refreshControl?.endRefreshing()
            
            snapshot?.documents.forEach { document in
                let postId = document.documentID
                
                Firestore.firestore().collection("posts").document(postId).getDocument { (snapshot, error) in
                    if let err = error {
                        print("Failed to get post liked: ", err)
                        return
                    }
                    
                    guard let userId = snapshot?.data()?["userId"] as? String else { return }
                    guard let dictionary = snapshot?.data() else { return }
                    
                    Firestore.fetchUserWithUID(uid: userId) { (user) in
                        var post = Post(user: user, dictionary: dictionary)
                        
                        // User already liked this post!
                        post.hasLiked = true
                        
                        self.items.append(post)
                        
                        self.items.sort { $0.creationDate > $1.creationDate }
                    }
                }
            }
            
            //self.items.sort { $0.creationDate > $1.creationDate }
            
            DispatchQueue.main.async {
                
                self.collectionView.reloadData()
            }
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell
        
        cell.item = self.items[indexPath.item]
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 40 + 8 * 2 // user profile image + gaps
        height += view.frame.width
        height += 50 // space for buttons
        height += 80 // caption
        
        return .init(width: view.frame.width, height: height)
    }
}


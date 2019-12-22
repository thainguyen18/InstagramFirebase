//
//  RibbonController.swift
//  InstagramFirebase
//
//  Created by Thai Nguyen on 12/21/19.
//  Copyright © 2019 Thai Nguyen. All rights reserved.
//

import UIKit
import LBTATools
import Firebase

class RibbonController: LBTAListController<HomePostCell, Post>, UICollectionViewDelegateFlowLayout, HomePostCellDelegate {
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        
        collectionView.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        
        let refreshControll = UIRefreshControl()
        refreshControll.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControll
        
        fetchRibbonPosts()
        
    }
    
    @objc func handleRefresh() {
        
        // Remove old data
        self.items.removeAll()
        
        fetchRibbonPosts()

    }
    
    
    fileprivate func fetchRibbonPosts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.fetchUserWithUID(uid: uid) { (user) in
            self.navigationItem.title = user.username
        }
        
        Firestore.firestore().collection("ribbons").document(uid).collection("postsRibbon").getDocuments { (snapshot, error) in
            if let err = error {
                print("Failed to fetch posts ribboned: ", err)
                return
            }
            
            self.collectionView.refreshControl?.endRefreshing()
            
            snapshot?.documents.forEach { document in
                let postId = document.documentID
                
                Firestore.firestore().collection("posts").document(postId).getDocument { (snapshot, error) in
                    if let err = error {
                        print("Failed to get post ribboned: ", err)
                        return
                    }
                    
                    guard let userId = snapshot?.data()?["userId"] as? String else { return }
                    guard let dictionary = snapshot?.data() else { return }
                    
                    Firestore.fetchUserWithUID(uid: userId) { (user) in
                        var post = Post(user: user, dictionary: dictionary)
                        
                        post.id = postId
                        
                        // User already ribboned this post!
                        post.hasRibboned = true
                        
                        self.items.append(post)
                        
                        self.items.sort { $0.creationDate > $1.creationDate }
                    }
                }
            }
            
            //self.items.sort { $0.creationDate > $1.creationDate }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                
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
    
    
    func didTapRibbon(for cell: HomePostCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        var post = self.items[indexPath.item]
        
        guard let postId = post.id else { return }
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        //Toggle the like button
        post.hasRibboned = !post.hasRibboned
        
        // Because of struct value, we need to set the value in array to this modified value
        self.items[indexPath.item] = post
        
        let ref = Firestore.firestore().collection("ribbons").document(uid).collection("postsRibbon").document(postId)
        
        if cell.item.hasRibboned {
            ref.delete() { (error) in
                if let err = error {
                    print("Failed to unribbon: ", err)
                    return
                }
                
                print("Successfully unribboned")
                
                DispatchQueue.main.async {
                    self.collectionView.reloadItems(at: [indexPath])
                }
            }
        } else {
            ref.setData([:]) { (error) in
                if let err = error {
                    print("Failed to ribbon: ", err)
                    return
                }
                
                print("Successfully ribboned")
                
                DispatchQueue.main.async {
                    self.collectionView.reloadItems(at: [indexPath])
                }
            }
        }
    }
    
    
    func didTapComment(post: Post) {
        
        let commentsController = CommentsController()
        commentsController.post = post
        
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    
    func didLike(for cell: HomePostCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        var post = self.items[indexPath.item]
        
        guard let postId = post.id else { return }
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        //Toggle the like button
        post.hasLiked = !post.hasLiked
        
        // Because of struct value, we need to set the value in array to this modified value
        self.items[indexPath.item] = post
        
        let ref = Firestore.firestore().collection("likes").document(uid).collection("postsLike").document(postId)
        
        if cell.item.hasLiked {
            ref.delete() { (error) in
                if let err = error {
                    print("Failed to unlike: ", err)
                    return
                }
                
                print("Successfully unliked")
                
                DispatchQueue.main.async {
                    self.collectionView.reloadItems(at: [indexPath])
                }
            }
        } else {
            ref.setData([:]) { (error) in
                if let err = error {
                    print("Failed to like: ", err)
                    return
                }
                
                print("Successfully liked")
                
                DispatchQueue.main.async {
                    self.collectionView.reloadItems(at: [indexPath])
                }
            }
        }
    }
}

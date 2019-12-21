//
//  HomeController.swift
//  InstagramFirebase
//
//  Created by Thai Nguyen on 12/6/19.
//  Copyright © 2019 Thai Nguyen. All rights reserved.
//

import UIKit
import SwiftUI
import LBTATools
import Firebase



class HomeController: LBTAListController<HomePostCell, Post>, UICollectionViewDelegateFlowLayout, HomePostCellDelegate {
    
    let cellId = "CellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: SharePhotoController.updateFeedNotificationName, object: nil)
        
        collectionView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        
        setupNavigationItems()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        collectionView.refreshControl = refreshControl
        
        fetchAllPosts()
    }
    
    @objc func handleUpdateFeed() {
        handleRefresh()
    }
    
    @objc func handleRefresh() {
        
        // Remove old data
        self.items.removeAll()
        
        fetchAllPosts()
    }
    
    fileprivate func fetchAllPosts() {
        fetchPosts()
        
        fetchFollowingUserIds()
    }
    
    fileprivate func fetchFollowingUserIds() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("following").document(uid).collection("follows").getDocuments { (snapshot, error) in
            if let err = error {
                print("Failed to fetch following users ", err)
                return
            }
            
            snapshot?.documents.forEach { document in
                let userId = document.documentID
                
                Firestore.fetchUserWithUID(uid: userId) { (user) in
                    self.fetchPostsWithUser(user: user)
                }
            }
        }
    }
    
    func setupNavigationItems() {
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo2"))
        
         navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "camera3").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleCamera))
    }
    
    @objc func handleCamera() {
        let cameraController = CameraController()
        
        cameraController.modalPresentationStyle = .fullScreen
        present(cameraController, animated: true)
    }
    
    // Fetch posts from current logged in user
    fileprivate func fetchPosts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.fetchUserWithUID(uid: uid) { user in
            self.fetchPostsWithUser(user: user)
        }
    }
    
    fileprivate func fetchPostsWithUser(user: User) {
        
        let ref = Firestore.firestore().collection("posts").whereField("userId", isEqualTo: user.uid).order(by: "creationDate", descending: true).limit(to: 20)
        
        ref.getDocuments { (querySnapshot, error) in
            
            self.collectionView.refreshControl?.endRefreshing()
            
            if let err = error {
                print("Failed to fetch user posts: ", err)
                
                return
            }
            
            guard let snapshot = querySnapshot else { return }
            
            snapshot.documents.forEach { document in
                
                var post = Post(user: user, dictionary: document.data())
                
                post.id = document.documentID
                
                // Check if current user liked this post
                guard let uid = Auth.auth().currentUser?.uid else { return }
                
                Firestore.firestore().collection("likes").document(uid).collection("postsLike").getDocuments { (snapshot, error) in
                    if let err = error {
                        print("Failed to fetch likes ", err)
                        return
                    }
                    
                    snapshot?.documents.forEach { document in
                        if document.documentID == post.id {
                            post.hasLiked = true
                            return
                        }
                    }
                    
                    self.items.append(post)
                    
                    self.items.sort { $0.creationDate > $1.creationDate }
                    
                    DispatchQueue.main.async {
                        
                        self.collectionView.reloadData()
                    }
                }
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


struct HomePreview: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
                .navigationBarTitle("Home", displayMode: .inline)
        }
    }
    
    struct HomeView: UIViewControllerRepresentable {
        func updateUIViewController(_ uiViewController: HomePreview.HomeView.UIViewControllerType, context: UIViewControllerRepresentableContext<HomePreview.HomeView>) {
            
        }
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<HomePreview.HomeView>) -> HomeController {
            return HomeController()
        }
    }
}

//
//  UserProfileController.swift
//  InstagramFirebase
//
//  Created by Thai Nguyen on 12/5/19.
//  Copyright © 2019 Thai Nguyen. All rights reserved.
//

import UIKit
import SwiftUI
import Firebase
import LBTATools


class UserProfilePhotoCell: LBTAListCell<Post> {
    override var item: Post! {
        didSet {
            self.imageView.loadImage(urlString: item.imageUrl)
        }
    }

    let imageView: CustomImageView = {
       let iv = CustomImageView()
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true

        return iv
    }()

    override func setupViews() {
        super.setupViews()

        addSubview(imageView)
        imageView.fillSuperview()
    }
}

class UserProfileController: LBTAListHeaderController<UserProfilePhotoCell, Post, UserProfileHeader>, UICollectionViewDelegateFlowLayout, UserProfileHeaderDelegate {
    
    var isGridView = true
    
    let cellId = "cellId"
    let homePostCellId = "homePostCellId"
   
    
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        
        //collectionView.alwaysBounceVertical = true
        
        collectionView.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(HomePostCell.self, forCellWithReuseIdentifier: homePostCellId)
        
        let refreshControll = UIRefreshControl()
        refreshControll.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControll
        
        fetchUser()
        
        setupLogOutButton()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdatePosts), name: SharePhotoController.updateFeedNotificationName, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateHeader), name: UserProfileHeader.updateHeaderData, object: nil)
    }
    
    @objc func handleRefresh() {
        
        if isRibbonView {
            didTapRibbonView()
            return
        }
        
        paginatePosts()
    }
    
    @objc func handleUpdatePosts() {
        print("Hey there is a new post please update it")
        isFinished = false
        //paginatePosts()
        
        fetchPosts()
    }
    
    
    @objc func handleUpdateHeader() {
        // Update number of posts to user database
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let ref = Firestore.firestore().collection("users").document(currentUserId)
        
        ref.getDocument { (snapshot, error) in
            if let err = error {
                print("Failed to update number of posts: ", err)
                return
            }
            
            guard let numberOfPosts = snapshot?.data()?["numberOfPosts"] as? Int else { return }
            
            Firestore.firestore().collection("users").document(currentUserId).updateData(["numberOfPosts" : numberOfPosts + 1]) { (error) in
                if let err = error {
                    print("Failed to update number of posts: ", err)
                    return
                }
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    
    
    private var listener: ListenerRegistration?
    
    private var lastSnapshot: QueryDocumentSnapshot?
    
    private var isFinished = false
    
    fileprivate func paginatePosts() {
        guard let uid = self.user?.uid else { return }
        
        guard let user = self.user else { return }
        
        guard !isFinished else {
            print("No new items...")
            
            isLoading = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.collectionView.refreshControl?.endRefreshing()
            }
            
            return
        }
        
        let refDB = Firestore.firestore().collection("posts").whereField("userId", isEqualTo: uid).order(by: "creationDate", descending: true).limit(to: 9)
        
        if let lastSnapshot = self.lastSnapshot {
            
            // Subsequence fetch i.e pagination
            refDB.start(afterDocument: lastSnapshot).getDocuments { (snapshot, error) in
                if let err = error {
                    print("Failed to fetch user posts: ", err)
                    return
                }
                
                self.collectionView.refreshControl?.endRefreshing()
                
                self.lastSnapshot = snapshot?.documents.last
                
                if let snapshot = snapshot, snapshot.documents.count < 9 {
                
                    self.isFinished = true
                }
                
                snapshot?.documents.forEach { document in
                    let post = Post(user: user, dictionary: document.data())
                    
                    self.items.append(post)
                }
                
                self.items.sort { $0.creationDate > $1.creationDate }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.isLoading = false

                    self.collectionView.reloadData()
                }
            }
        } else {
            // Initial fetch
            
            refDB.getDocuments { (snapshot, error) in
                if let err = error {
                    print("Failed to fetch user posts: ", err)
                    return
                }
                
                self.collectionView.refreshControl?.endRefreshing()
                
                self.lastSnapshot = snapshot?.documents.last
                
                snapshot?.documents.forEach { document in
                    let post = Post(user: user, dictionary: document.data())
                    
                    self.items.append(post)
                }
                
                self.items.sort { $0.creationDate > $1.creationDate }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.isLoading = false

                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    
    private var isLoading = false
    
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView.contentOffset.y > -60 && !isLoading {
//            isLoading = true
//            paginatePosts()
//        }
//    }
    
    
    // Using this fetch to get the most recent post
    fileprivate func fetchPosts() {
        
        guard let uid = self.user?.uid else { return }
        
        let ref = Firestore.firestore().collection("posts").whereField("userId", isEqualTo: uid).order(by: "creationDate", descending: true).limit(to: 1)
        
        self.listener = ref.addSnapshotListener { (querySnapshot, error) in
            if let err = error {
                print("Failed to fetch user posts: ", err)
                return
            }
            
            guard let snapshot = querySnapshot else { return }
            
            guard let user = self.user else { return }
            
            snapshot.documentChanges.forEach { diff in
                let post = Post(user: user, dictionary: diff.document.data())
                
                self.items.insert(post, at: 0)
            }
            
            self.items.sort { $0.creationDate > $1.creationDate }
            
            DispatchQueue.main.async {
                
                self.collectionView.reloadData()
                
                self.listener?.remove()
            }
            
        }
    }
    
    
    fileprivate func setupLogOutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogOut))
    }
    
    @objc func handleLogOut() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            do {
                try Auth.auth().signOut()
                
                // Present log in UI after signing out
                let loginController = LoginController()
                let nav = UINavigationController(rootViewController: loginController)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
                
                // Stop listening to database changes
                self.listener?.remove()
                
            } catch let signOutError {
                print("Failed to sign out: ", signOutError)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alertController, animated: true)
    }
    
    override func setupHeader(_ header: UserProfileHeader) {
        header.user = self.user
        
        // Set up UserProfileController to be delegate
        header.delegate = self
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if isRibbonView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homePostCellId, for: indexPath) as! HomePostCell
            cell.item = self.items[indexPath.item]
            return cell
        }
        
        if isGridView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfilePhotoCell
            cell.item = self.items[indexPath.item]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homePostCellId, for: indexPath) as! HomePostCell
            cell.item = self.items[indexPath.item]
            return cell
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: view.frame.width, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if isGridView {
            let width = (view.frame.width - 2 * 1) / 3
            return .init(width: width, height: width)
        } else {
            var height: CGFloat = 40 + 8 * 2 // user profile image + gaps
            height += view.frame.width
            height += 50 // space for buttons
            height += 80 // caption
            
            return .init(width: view.frame.width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    var user: User?
    var userId: String? // Use this property to load selected user from search controller
    
    fileprivate func fetchUser() {
        
        let uid = userId ?? Auth.auth().currentUser?.uid ?? ""
        
        Firestore.fetchUserWithUID(uid: uid) { (user) in
            self.user = user
                
            self.navigationItem.title = self.user?.username
            
            // Pass data after fetching and reload
            
            //self.fetchPosts()
            
            self.paginatePosts()
        }
    }
    
    func didChangeToGridView() {
        if isRibbonView {
            isRibbonView = false
            isGridView = true
            
            reFetchPosts()
            
            return
        }
        
        isGridView = true
        collectionView.reloadData()
        
    }
    
    func didChangeToListView() {
        if isRibbonView {
            isRibbonView = false
            isGridView = false
            
            reFetchPosts()
            
            return
        }
        
        isGridView = false
        collectionView.reloadData()
    }
    
    fileprivate func reFetchPosts() {
        guard let uid = self.user?.uid else { return }
        
        Firestore.fetchPostsWithUID(uid: uid) { (posts) in
            self.items = posts
        }
    }
    
    
    var isRibbonView = false
    
    
    func didTapRibbonView() {
        
        guard let uid = user?.uid else { return }
        
        isRibbonView = true
        isGridView = false
        
        // Remove all items
        self.items.removeAll()
        
        Firestore.firestore().collection("ribbons").document(uid).collection("postsRibbon").getDocuments { (querySnapshot, error) in
            if let err = error {
                print("Faild to fetch posts ribboned: ", err)
                return
            }
            
            self.collectionView.refreshControl?.endRefreshing()
            
            querySnapshot?.documents.forEach { document in
                let postId = document.documentID
                
                Firestore.firestore().collection("posts").document(postId).getDocument { (snapshot, error) in
                    if let err = error {
                        print("Failed to fetch posts: ", err)
                        return
                    }
                    
                    guard let dictionary = snapshot?.data(), let userId = dictionary["userId"] as? String else { return }
                    
                    Firestore.fetchUserWithUID(uid: userId) { (user) in
                        var post = Post(user: user, dictionary: dictionary)
                        post.id = postId
                        post.hasRibboned = true // User ribboned already
                        
                        // Check if user also liked this post
                        Firestore.firestore().collection("likes").document(uid).collection("postsLike").document(postId).getDocument { (snapshot, error) in
                            if let err = error {
                                print("Failed to fetch likes: ", err)
                                return
                            }
                            
                            if let document = snapshot, document.exists {
                                post.hasLiked = true
                            }
                            
                            self.items.append(post)
                            
                            self.items.sort { $0.creationDate > $1.creationDate }
                        }
                    }
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                
                self.collectionView.reloadData()
            }
        }
    }
}





//struct UserProfilePreview: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            UserProfileViewContainer()
//                .navigationBarTitle("Some user", displayMode: .inline)
//        }
//    }
//    
//    struct UserProfileViewContainer: UIViewControllerRepresentable {
//        func updateUIViewController(_ uiViewController: UserProfilePreview.UserProfileViewContainer.UIViewControllerType, context: UIViewControllerRepresentableContext<UserProfilePreview.UserProfileViewContainer>) {
//            
//        }
//        
//        func makeUIViewController(context: UIViewControllerRepresentableContext<UserProfilePreview.UserProfileViewContainer>) -> UserProfileController {
//            return UserProfileController()
//        }
//    }
//}

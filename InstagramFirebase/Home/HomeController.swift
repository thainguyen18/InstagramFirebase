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


class HomePostCell: LBTAListCell<Post> {
    override var item: Post! {
        didSet {
            photoImageView.loadImage(urlString: item.imageUrl)
            
            usernameLabel.text = item.user.username
            
            userProfileImageView.loadImage(urlString: item.user.profileImageUrl)
            
            captionLabel.text = item.caption
            
            setupAttributedCaption()
        }
    }
    
    fileprivate func setupAttributedCaption() {
        let attributedText = NSMutableAttributedString(string: item.user.username, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: " \(item.caption)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor.black]))
        
        attributedText.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 4), NSAttributedString.Key.foregroundColor : UIColor.black]))
        
        let creationDate = Date(timeIntervalSince1970: item.creationDate)
        
        attributedText.append(NSAttributedString(string: creationDate.timeAgoDisplay(), attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor.lightGray]))
        
        captionLabel.attributedText = attributedText
    }
    
    let photoImageView: CustomImageView = {
       let iv = CustomImageView()
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        
        return iv
    }()
    
    let userProfileImageView: CustomImageView = {
       let iv = CustomImageView()
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        
        return iv
    }()
    
    let usernameLabel : UILabel = {
       let label = UILabel()
        label.text = "username"
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .black
        //label.backgroundColor = .white
        label.numberOfLines = 0
        
        return label
    }()
    
    let optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("•••", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 24)
        button.setTitleColor(.black, for: .normal)
        
        return button
    }()
    
    let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
        
        return button
    }()
    
    let commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "comment").withRenderingMode(.alwaysOriginal), for: .normal)
        
        return button
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "send2").withRenderingMode(.alwaysOriginal), for: .normal)
        
        return button
    }()
    
    let ribbonButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon").withRenderingMode(.alwaysOriginal), for: .normal)
        
        return button
    }()
    
    let captionLabel: UILabel = {
        let label = UILabel()
        
        
        
        label.numberOfLines = 0
        
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        
        backgroundColor = .white
        
        userProfileImageView.layer.cornerRadius = 40 / 2
        
        addSubview(userProfileImageView)
        addSubview(usernameLabel)
        addSubview(photoImageView)
        addSubview(optionsButton)
        addSubview(captionLabel)
        
        userProfileImageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 8, left: 8, bottom: 0, right: 0), size: .init(width: 40, height: 40))
        
        
        usernameLabel.anchor(top: topAnchor, leading: userProfileImageView.trailingAnchor, bottom: photoImageView.topAnchor, trailing: optionsButton.leadingAnchor, padding: .init(top: 0, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 0))
        
       
        photoImageView.anchor(top: userProfileImageView.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 8, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: frame.width))
        
        optionsButton.anchor(top: topAnchor, leading: nil, bottom: photoImageView.topAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 8), size: .init(width: 0, height: 0))
        
        setupActionButtons()
        
        captionLabel.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 8, bottom: 8, right: 8), size: .init(width: 0, height: 80))
    }
    
    fileprivate func setupActionButtons() {
        let stackViews = UIStackView(arrangedSubviews: [likeButton, commentButton, sendButton, UIView(), ribbonButton])
        stackViews.spacing = 30
        stackViews.axis = .horizontal
        stackViews.distribution = .fill
        stackViews.backgroundColor = .cyan
        
        addSubview(stackViews)
        
        stackViews.anchor(top: photoImageView.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 0, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 50))
    }
}

class HomeController: LBTAListController<HomePostCell, Post>, UICollectionViewDelegateFlowLayout {
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        Firestore.firestore().collection("following").document(uid).getDocument { (snapshot, error) in
            if let err = error {
                print("Failed to fetch following users ", err)
                return
            }
            
            guard let followingUsersDict = snapshot?.data() else { return }
            
            followingUsersDict.forEach { (userId, _) in
                Firestore.fetchUserWithUID(uid: userId) { (user) in
                    self.fetchPostsWithUser(user: user)
                }
            }
        }
    }
    
    fileprivate func setupNavigationItems() {
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo2"))
    }
    
    // Fetch posts from current logged in user
    fileprivate func fetchPosts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.fetchUserWithUID(uid: uid) { user in
            self.fetchPostsWithUser(user: user)
        }
    }
    
    fileprivate func fetchPostsWithUser(user: User) {
        
        let ref = Firestore.firestore().collection("posts").document(user.uid).collection("userposts").order(by: "creationDate", descending: true).limit(to: 20)
        
        ref.getDocuments { (querySnapshot, error) in
            
            self.collectionView.refreshControl?.endRefreshing()
            
            if let err = error {
                print("Failed to fetch user posts: ", err)
                
                return
            }
            
            guard let snapshot = querySnapshot else { return }
            
            snapshot.documents.forEach { document in
                
                let post = Post(user: user, dictionary: document.data())
                
                self.items.append(post)
            }
            
            print(self.items.count)
            
            self.items.sort { $0.creationDate > $1.creationDate }
            
            DispatchQueue.main.async {
                
                self.collectionView.reloadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 40 + 8 * 2 // user profile image + gaps
        height += view.frame.width
        height += 50 // space for buttons
        height += 80 // caption
        
        return .init(width: view.frame.width, height: height)
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

//
//  UserProfileHeader.swift
//  InstagramFirebase
//
//  Created by Thai Nguyen on 12/5/19.
//  Copyright © 2019 Thai Nguyen. All rights reserved.
//

import UIKit
import LBTATools
import Firebase

protocol UserProfileHeaderDelegate {
    func didChangeToListView()
    func didChangeToGridView()
    func didTapRibbonView()
}

class UserProfileHeader: UICollectionReusableView {
    
    var delegate: UserProfileHeaderDelegate?
    
    static let updateHeaderData = Notification.Name("updateData")
    
    var user: User? {
        didSet {
            
            guard let imageUrl = user?.profileImageUrl else { return }
            
            imageView.loadImage(urlString: imageUrl)
            
            nameLabel.text = user?.username
            
            setupEditFollowButton()
            
            fetchNumberOfPosts()
            
            fetchNumberOfFollowers()
            
            fetchNumberOfFollowings()
        }
    }
    
    
    fileprivate func fetchNumberOfPosts() {
        
        guard let userId = user?.uid else { return }
        
        Firestore.firestore().collection("posts").whereField("userId", isEqualTo: userId).getDocuments { (querySnapshot, error) in
            if let err = error {
                print("Failed to fetch user posts: ", err)
                return
            }
            
            let numberOfPosts = querySnapshot?.documents.count ?? 0
            
            self.postsLabel.text = "\(numberOfPosts)"
        }
    }
    
    fileprivate func fetchNumberOfFollowers() {
        guard let userId = user?.uid else { return }
        
        Firestore.firestore().collection("followers").document(userId).collection("followedBy").getDocuments { (querySnapshot, error) in
            if let err = error {
                print("Failed to fetch user followed: ", err)
                return
            }
            
            let numberOfFollowers = querySnapshot?.documents.count ?? 0
            
            self.followersLabel.text = "\(numberOfFollowers)"
        }
    }
    
    fileprivate func fetchNumberOfFollowings() {
        guard let userId = user?.uid else { return }
        
        Firestore.firestore().collection("following").document(userId).collection("follows").getDocuments { (querySnapshot, error) in
            if let err = error {
                print("Failed to fetch user followings: ", err)
                return
            }
            
            let numberOfFollowings = querySnapshot?.documents.count ?? 0
            
            self.followingLabel.text = "\(numberOfFollowings)"
        }
    }
    
    fileprivate func setupEditFollowButton() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        guard let userId = user?.uid else { return }
        
        if currentUserId == userId {
            editButton.setTitle("Edit Profile", for: .normal)
        } else {
            
            // Check for following info
            Firestore.firestore().collection("following").document(currentUserId).collection("follows").getDocuments { (querySnapshot, error) in
                if let err = error {
                    print("Failed to check if followed: ", err)
                    return
                }
                
                // Not following
                self.setupFollowStyle(following: false)
                
                querySnapshot?.documents.forEach { document in
                    if document.documentID == userId {
                        // Following
                        self.setupFollowStyle(following: true)
                        
                        return
                    }
                }
            }
        }
        
    }
    
    @objc func handleEditProfileOrFollow() {
        // If current user profile then return
        if editButton.titleLabel?.text == "Edit Profile" { return }
        
        guard let currentUserId = Auth.auth().currentUser?.uid  else { return }
        guard let uid = user?.uid else { return }
        
        if editButton.titleLabel?.text == "Unfollow" {

            let ref = Firestore.firestore().collection("following").document(currentUserId).collection("follows")
            
            ref.document(uid).delete { (error) in
                if let err = error {
                    print("Failed to unfollow: ", err)
                    return
                }
                print("Successfully unfollowed user: ", self.user?.username ?? "")
                
                // Not following UI
                self.setupFollowStyle(following: false)
            }
            
            // Remove data from followers database
            Firestore.firestore().collection("followers").document(uid).collection("followedBy").document(currentUserId).delete { (error) in
                if let err = error {
                    print("Failed to unfollow: ", err)
                    return
                }
                print(self.user?.username ?? "", "lost a follower")
            }
            
            
            
        } else {
            let ref = Firestore.firestore().collection("following").document(currentUserId).collection("follows")
            
            ref.document(uid).setData([:]) { (error) in
                if let err = error {
                    print("Failed to follow: ", err)
                    return
                }
                
                print("Successfully followed user: ", self.user?.username ?? "")
                
                self.setupFollowStyle(following: true)
            }
            
            // Push data to followers database
            Firestore.firestore().collection("followers").document(uid).collection("followedBy").document(currentUserId).setData([:]) { (error) in
                if let err = error {
                    print("Failed to follow: ", err)
                    return
                }
                
                print(self.user?.username ?? "", " had a new follower: ", currentUserId)
            }
           
        }
        
        // Post notification for updating data on header
        NotificationCenter.default.post(name: UserProfileHeader.updateHeaderData, object: nil)
    }
    
    fileprivate func setupFollowStyle(following: Bool) {
        if following {
            // Update UI Following
            self.editButton.setTitle("Unfollow", for: .normal)
            self.editButton.backgroundColor = .clear
            self.editButton.setTitleColor(.black, for: .normal)
        } else {
            // Not following UI
            self.editButton.setTitle("Follow", for: .normal)
            self.editButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
            self.editButton.setTitleColor(.white, for: .normal)
        }
    }
    
    let imageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = .green
        
        return iv
    }()

    let nameLabel = UILabel(text: "username", font: .boldSystemFont(ofSize: 14), textColor: .black, textAlignment: .center, numberOfLines: 0)

    let postsLabel = UILabel(text: "0", font: .boldSystemFont(ofSize: 14), textColor: .black, textAlignment: .center, numberOfLines: 1)

    let followersLabel = UILabel(text: "0", font: .boldSystemFont(ofSize: 14), textColor: .black, textAlignment: .center, numberOfLines: 1)

    let followingLabel = UILabel(text: "0", font: .boldSystemFont(ofSize: 14), textColor: .black, textAlignment: .center, numberOfLines: 1)

    let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.layer.cornerRadius = 8
        button.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
        button.layer.borderWidth = 2
        
        button.addTarget(self, action: #selector(handleEditProfileOrFollow), for: .touchUpInside)

        return button
    }()
    
    
    lazy var gridButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        button.addTarget(self, action: #selector(handleChangeToGridView), for: .touchUpInside)
        return button
    }()
    
    @objc func handleChangeToGridView() {
        listButton.tintColor = UIColor(white: 0, alpha: 0.2)
        gridButton.tintColor = .mainBlue()
        ribbonButton.tintColor = UIColor(white: 0, alpha: 0.2)
        
        delegate?.didChangeToGridView()
    }
    
    lazy var listButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        button.addTarget(self, action: #selector(handleChangeToListView), for: .touchUpInside)
        return button
    }()
    
    @objc func handleChangeToListView() {
        listButton.tintColor = UIColor.mainBlue()
        gridButton.tintColor = UIColor(white: 0, alpha: 0.2)
        ribbonButton.tintColor = UIColor(white: 0, alpha: 0.2)
        
        delegate?.didChangeToListView()
    }
    
    let ribbonButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon_selected"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        button.addTarget(self, action: #selector(handleRibbonView), for: .touchUpInside)
        return button
    }()
    
    @objc func handleRibbonView() {
        ribbonButton.tintColor = UIColor.mainBlue()
        listButton.tintColor = UIColor(white: 0, alpha: 0.2)
        gridButton.tintColor = UIColor(white: 0, alpha: 0.2)
        
        delegate?.didTapRibbonView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.layer.cornerRadius = 80 / 2
        imageView.clipsToBounds = true
        
        let topDivider = UIView()
        topDivider.backgroundColor = UIColor(white: 0, alpha: 0.2)
        
        let bottomDivider = UIView()
        bottomDivider.backgroundColor = UIColor(white: 0, alpha: 0.2)
        
        stack(
            hstack(
                stack(imageView.withSize(.init(width: 80, height: 80)), nameLabel, UIView(), spacing: 20),
                stack(
                    hstack(
                        stack(postsLabel, UILabel(text: "posts", textColor: .lightGray, textAlignment: .center)),
                        stack(followersLabel, UILabel(text: "followers", textColor: .lightGray, textAlignment: .center)),
                        stack(followingLabel, UILabel(text: "following", textColor: .lightGray, textAlignment:  .center)),
                        distribution: .fillEqually
                        ),
                    editButton.withHeight(30),
                    UIView(),
                    spacing: 20
                ).padRight(20),
                spacing: 20
            ).padLeft(12).padTop(12),
            topDivider.withHeight(1),
            hstack(gridButton, listButton, ribbonButton, distribution: .fillEqually).withHeight(40),
            bottomDivider.withHeight(1),
            spacing: 4
        )
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

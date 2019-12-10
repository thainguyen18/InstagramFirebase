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

class UserProfileHeader: UICollectionReusableView {
    
    var user: User? {
        didSet {
            
            guard let imageUrl = user?.profileImageUrl else { return }
            
            imageView.loadImage(urlString: imageUrl)
            
            nameLabel.text = user?.username
            
            setupEditFollowButton()
        }
    }
    
    fileprivate func setupEditFollowButton() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        guard let userId = user?.uid else { return }
        
        if currentUserId == userId {
            editButton.setTitle("Edit Profile", for: .normal)
        } else {
            
            // Checking if following already
            Firestore.firestore().collection("following").document(currentUserId).getDocument { (snapshot, error) in
                if let err = error {
                    print("Failed to check if followed: ", err)
                    return
                }
                
                if let isFollowing = snapshot?.data()?[userId] as? Int, isFollowing == 1 {
                    // Following
                    self.setupFollowStyle(following: true)

                } else {
                    // Not following
                    self.setupFollowStyle(following: false)
                }
            }
        }
        
    }
    
    @objc func handleEditProfileOrFollow() {
        guard let currentUserId = Auth.auth().currentUser?.uid  else { return }
        guard let uid = user?.uid else { return }
        
        if editButton.titleLabel?.text == "Unfollow" {
            Firestore.firestore().collection("following").document(currentUserId).updateData([uid : FieldValue.delete()]) { (error) in
                if let err = error {
                    print("Failed to unfollow: ", err)
                    return
                }
                print("Successfully unfollowed user: ", self.user?.username ?? "")
                
                // Not following UI
                self.setupFollowStyle(following: false)
            }
        } else {
            let ref = Firestore.firestore().collection("following").document(currentUserId)
            
            ref.setData([uid : 1], merge: true) { (error) in
                if let err = error {
                    print("Failed to follow: ", err)
                    return
                }
                
                print("Successfully followed user: ", self.user?.username ?? "")
                
                self.setupFollowStyle(following: true)
            }
        }
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

    let postsLabel = UILabel(text: "10", font: .boldSystemFont(ofSize: 14), textColor: .black, textAlignment: .center, numberOfLines: 1)

    let followersLabel = UILabel(text: "0", font: .boldSystemFont(ofSize: 14), textColor: .black, textAlignment: .center, numberOfLines: 1)

    let followingLabel = UILabel(text: "0", font: .boldSystemFont(ofSize: 14), textColor: .black, textAlignment: .center, numberOfLines: 1)

    let editButton: UIButton = {
        let button = UIButton(type: .system)
        //button.setTitle("", for: .normal)
        //button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.layer.cornerRadius = 8
        button.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
        button.layer.borderWidth = 2
        
        button.addTarget(self, action: #selector(handleEditProfileOrFollow), for: .touchUpInside)

        return button
    }()
    
    
    let gridButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        return button
    }()
    
    let listButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    let ribbonButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
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

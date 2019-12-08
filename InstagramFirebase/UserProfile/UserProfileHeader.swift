//
//  UserProfileHeader.swift
//  InstagramFirebase
//
//  Created by Thai Nguyen on 12/5/19.
//  Copyright © 2019 Thai Nguyen. All rights reserved.
//

import UIKit
import LBTATools

class UserProfileHeader: UICollectionReusableView {
    
    var user: User? {
        didSet {
            
            guard let imageUrl = user?.profileImageUrl else { return }
            
            imageView.loadImage(urlString: imageUrl)
            
            nameLabel.text = user?.username
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
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.layer.cornerRadius = 8
        button.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
        button.layer.borderWidth = 2

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

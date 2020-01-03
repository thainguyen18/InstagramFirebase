//
//  HomePostCell.swift
//  InstagramFirebase
//
//  Created by Thai Nguyen on 12/20/19.
//  Copyright © 2019 Thai Nguyen. All rights reserved.
//

import LBTATools
import UIKit

protocol HomePostCellDelegate {
    func didTapComment(post: Post)
    
    func didLike(for cell: HomePostCell)
    
    func didTapRibbon(for cell: HomePostCell)
    
    func didTapOptions(for cell: HomePostCell)
    
    func didTapSend(for cell: HomePostCell)
}


class HomePostCell: LBTAListCell<Post> {
    
    var delegate: HomePostCellDelegate?
    
    override var item: Post! {
        didSet {
            
            photoImageView.loadImage(urlString: item.imageUrl)
            
            usernameLabel.text = item.user.username
            
            userProfileImageView.loadImage(urlString: item.user.profileImageUrl)
            
            captionLabel.text = item.caption
            
            setupAttributedCaption()
            
            likeButton.setImage(item.hasLiked ? #imageLiteral(resourceName: "like_selected").withRenderingMode(.alwaysOriginal) : #imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
            
            ribbonButton.setImage(item.hasRibboned ? #imageLiteral(resourceName: "ribbon_selected").withRenderingMode(.alwaysOriginal) : #imageLiteral(resourceName: "ribbon").withRenderingMode(.alwaysOriginal), for: .normal)
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
    
    lazy var optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("•••", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 24)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleOptions), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleOptions() {
        print("Handle options...")
        
        delegate?.didTapOptions(for: self)
    }
    
    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        
        return button
    }()
    
    @objc func handleLike() {
        print("Handling like...")
        delegate?.didLike(for: self)
    }
    
    lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "comment").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return button
    }()
    
    @objc func handleComment() {
        print("Handling comment...")
        delegate?.didTapComment(post: self.item)
    }
    
    lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "send2").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    
    @objc fileprivate func handleSend() {
        print("Handle sending...")
        delegate?.didTapSend(for: self)
    }
    
    lazy var ribbonButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleTapRibbon), for: .touchUpInside)
        
        return button
    }()
    
    @objc func handleTapRibbon() {
        print("Handling ribbon...")
        delegate?.didTapRibbon(for: self)
    }
    
    let captionLabel: UILabel = {
        let label = UILabel()
        
        label.numberOfLines = 0
        
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        
        backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        
        self.layer.cornerRadius = 15
        
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

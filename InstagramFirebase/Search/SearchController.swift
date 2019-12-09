//
//  SearchController.swift
//  InstagramFirebase
//
//  Created by Thai Nguyen on 12/6/19.
//  Copyright © 2019 Thai Nguyen. All rights reserved.
//

import UIKit
import LBTATools

class UserSearchCell: LBTAListCell<String> {
    
    let profileImageView: CustomImageView = {
       let iv = CustomImageView()
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        iv.backgroundColor = .green
        
        return iv
    }()
    
    let usernameLabel: UILabel = {
       let label = UILabel()
        label.backgroundColor = .yellow
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .black
        label.text = "Username"
        return label
    }()
    
    let numberOfPostsLabel: UILabel = {
       let label = UILabel()
        label.backgroundColor = .purple
        label.font = .systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.text = "3 posts"
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        
        // Size for circular profile image view
        let width = frame.height - 2 * 8
        
        profileImageView.layer.cornerRadius = width / 2
        
        addSubview(profileImageView)
        
        profileImageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: nil, padding: .init(top: 8, left: 8, bottom: 8, right: 0), size: .init(width: width, height: width))
        
        let stackViews = UIStackView(arrangedSubviews: [usernameLabel, numberOfPostsLabel])
        stackViews.axis = .vertical
        stackViews.distribution = .fillEqually
        stackViews.alignment = .fill
        
        addSubview(stackViews)
        stackViews.anchor(top: profileImageView.topAnchor, leading: profileImageView.trailingAnchor, bottom: profileImageView.bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 8, bottom: 0, right: 8))
        
        let separator = UIView()
        separator.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        addSubview(separator)
        separator.anchor(top: nil, leading: stackViews.leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 0.5))
    }
}

class SearchController: LBTAListController<UserSearchCell, String>, UICollectionViewDelegateFlowLayout {
    
    let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Enter username"
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        
        return sb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        navigationController?.navigationBar.addSubview(searchBar)
        
        let navBar = navigationController?.navigationBar
        
        searchBar.anchor(top: navBar?.topAnchor, leading: navBar?.leadingAnchor, bottom: navBar?.bottomAnchor, trailing: navBar?.trailingAnchor, padding: .init(top: 0, left: 8, bottom: 0, right: 8))
        
        items = ["1", "2", "3", "4"]
        
        collectionView.alwaysBounceVertical = true
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: 60)
    }
}

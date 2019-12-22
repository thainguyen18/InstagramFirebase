//
//  SearchController.swift
//  InstagramFirebase
//
//  Created by Thai Nguyen on 12/6/19.
//  Copyright © 2019 Thai Nguyen. All rights reserved.
//

import UIKit
import LBTATools
import Firebase

class UserSearchCell: LBTAListCell<User> {
    
    override var item: User! {
        didSet {
            profileImageView.loadImage(urlString: item.profileImageUrl)
            
            usernameLabel.text = item.username
            
            var text = "\(item.numberOfPosts)"
            
            if item.numberOfPosts == 1 || item.numberOfPosts == 0 {
                text.append(" post")
            } else {
                text.append(" posts")
            }
            
            numberOfPostsLabel.text = text
        }
    }
    
    let profileImageView: CustomImageView = {
       let iv = CustomImageView()
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        iv.backgroundColor = .green
        
        return iv
    }()
    
    let usernameLabel: UILabel = {
       let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .black
        label.text = "Username"
        return label
    }()
    
    let numberOfPostsLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.text = "0 posts"
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

class SearchController: LBTAListController<UserSearchCell, User>, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Enter username"
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        
        return sb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        navigationController?.navigationBar.addSubview(searchBar)
        
        searchBar.delegate = self
        
        let navBar = navigationController?.navigationBar
        
        searchBar.anchor(top: navBar?.topAnchor, leading: navBar?.leadingAnchor, bottom: navBar?.bottomAnchor, trailing: navBar?.trailingAnchor, padding: .init(top: 0, left: 8, bottom: 0, right: 8))
        
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        fetchUsers()
    }
    
    
    @objc func handleRefresh() {
        //Reset data
        self.usersMasterList.removeAll()
        self.items.removeAll()
        
        fetchUsers()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.items = []
            return
        }
        
        self.items = self.usersMasterList.filter { $0.username.lowercased().contains(searchText.lowercased()) }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchBar.isHidden = false
    }
    
    private var usersMasterList = [User]()
    
    fileprivate func fetchUsers() {
        Firestore.firestore().collection("users").order(by: "username", descending: false).getDocuments { (snapshot, error) in
            if let err = error {
                print("Failed to fetch users ", err)
                return
            }
            
            self.collectionView.refreshControl?.endRefreshing()
            
            snapshot?.documents.forEach { document in
                let userId = document.documentID
                
                // Remove ourselves the current user
                if Auth.auth().currentUser?.uid != userId {
                    let user = User(uid: document.documentID, dictionary: document.data())
                    
                    
                    //self.items.append(user)
                    self.usersMasterList.append(user)
                }
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        
        let selectedUser = self.usersMasterList[indexPath.item]
        
        let userProfileController = UserProfileController()
        userProfileController.userId = selectedUser.uid
        
        navigationController?.pushViewController(userProfileController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: 60)
    }
}

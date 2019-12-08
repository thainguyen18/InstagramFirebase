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


class PhotoCell: LBTAListCell<Post> {
    override var item: Post! {
        
        didSet {
            self.imageView.loadImage(urlString: item.imageUrl)
        }
    }
    
    let imageView: CustomImageView = {
       let iv = CustomImageView()
        iv.backgroundColor = .blue
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

class UserProfileController: LBTAListHeaderController<PhotoCell, Post, UserProfileHeader>, UICollectionViewDelegateFlowLayout {
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        
        navigationItem.title = "Some user"
        
        fetchUser()
        
        //fetchPosts()
        
        setupLogOutButton()
    }
    
    private var listener: ListenerRegistration?
    
    fileprivate func fetchPosts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let ref = Firestore.firestore().collection("posts").document(uid).collection("userposts").order(by: "creationDate", descending: true).limit(to: 10)
        
        self.listener = ref.addSnapshotListener { (querySnapshot, error) in
            if let err = error {
                print("Failed to fetch user posts: ", err)
                return
            }
            
            guard let snapshot = querySnapshot else { return }
            
            snapshot.documentChanges.forEach { diff in
                let post = Post(dictionary: diff.document.data())
                
                self.items.insert(post, at: 0)
            }
            
            DispatchQueue.main.async {
                self.items.sort { $0.creationDate > $1.creationDate }
                
                self.collectionView.reloadData()
            }
            
        }
    }
    
    // Stop listening to database changes
    deinit {
        self.listener?.remove()
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
                
            } catch let signOutError {
                print("Failed to sign out: ", signOutError)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alertController, animated: true)
    }
    
    override func setupHeader(_ header: UserProfileHeader) {
        header.user = self.user
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: view.frame.width, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2 * 1) / 3
        return .init(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    var user: User?
    
    fileprivate func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let docRef = Firestore.firestore().collection("users").document(uid)
        
        docRef.getDocument { (snapShot, error) in
            if let err = error {
                print("Failed to fetch user info: ", err)
                return
            }
            
            if let userData = snapShot, userData.exists, let dictionary = userData.data() {
                
                self.user = User(dictionary: dictionary)
                    
                self.navigationItem.title = self.user?.username
                
                // Pass data after fetching and reload
                self.fetchPosts()
//                DispatchQueue.main.async {
//                    self.collectionView.reloadData()
//                }
               
            } else {
                print("Document does not exist")
            }
        }
    }
}


class User {
    var username: String
    var profileImageUrl: String
    
    init(dictionary: [String:Any]) {
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
    }
}


struct UserProfilePreview: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UserProfileViewContainer()
                .navigationBarTitle("Some user", displayMode: .inline)
        }
    }
    
    struct UserProfileViewContainer: UIViewControllerRepresentable {
        func updateUIViewController(_ uiViewController: UserProfilePreview.UserProfileViewContainer.UIViewControllerType, context: UIViewControllerRepresentableContext<UserProfilePreview.UserProfileViewContainer>) {
            
        }
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<UserProfilePreview.UserProfileViewContainer>) -> UserProfileController {
            return UserProfileController()
        }
    }
}

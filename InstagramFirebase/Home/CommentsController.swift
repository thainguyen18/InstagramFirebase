//
//  CommentController.swift
//  InstagramFirebase
//
//  Created by Thai Nguyen on 12/11/19.
//  Copyright © 2019 Thai Nguyen. All rights reserved.
//

import UIKit
import LBTATools
import Firebase

class CommentCell: LBTAListCell<Comment> {
    
    override var item: Comment! {
        didSet {
            
            let attributedString = NSMutableAttributedString(string: item.user.username, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
            
            attributedString.append(NSAttributedString(string: " " + item.text, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]))
            
            self.commentTextView.attributedText = attributedString
            
            self.profileImageView.loadImage(urlString: item.user.profileImageUrl)
        }
    }
    
    let commentTextView: UITextView = {
        let tv = UITextView()
        tv.isScrollEnabled = false
        tv.isEditable = false
        
        return tv
    }()
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .red
        
        return iv
    }()
    
    override func setupViews() {
        super.setupViews()
        
        profileImageView.layer.cornerRadius = 40 / 2
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 8, left: 8, bottom: 0, right: 0), size: .init(width: 40, height: 40))
        
        addSubview(commentTextView)
        commentTextView.anchor(top: topAnchor, leading: profileImageView.trailingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 4, left: 4, bottom: 4, right: 4))
        
        addSeparatorView(leadingAnchor: profileImageView.trailingAnchor)
    }
}

class CommentsController: LBTAListController<CommentCell, Comment>, UICollectionViewDelegateFlowLayout, CommentInputAccessoryViewDelegate {
    
    var post: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Comments"
        
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        
        
        collectionView.contentInset = .init(top: 0, left: 0, bottom: 50, right: 0)
        collectionView.scrollIndicatorInsets = .init(top: 0, left: 0, bottom: 50, right: 0)
        
        // Listen to keyboard notification to scroll to bottom of collection view
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UITextView.textDidBeginEditingNotification, object: nil)
        
        fetchComments()
    }
    
    @objc func handleKeyboardShow() {
        let lastIndexPath = NSIndexPath(item: self.items.count - 1, section: 0)
        collectionView.scrollToItem(at: lastIndexPath as IndexPath, at: .bottom, animated: true)
    }
    
    private var listener: ListenerRegistration?
    
    fileprivate func fetchComments() {
        guard let postId = self.post?.id else { return }
        
        self.listener = Firestore.firestore().collection("comments").document(postId).collection("userComments").order(by: "creationDate", descending: false).addSnapshotListener { (querySnapshot, error) in
            if let err = error {
                print("Failed to fetch comments: ", err)
                return
            }
            
            querySnapshot?.documentChanges.forEach { documentChange in
                
                guard let uid = documentChange.document.data()["userId"] as? String else { return }
                
                Firestore.fetchUserWithUID(uid: uid) { (user) in
                    let comment = Comment(user: user, dictionary: documentChange.document.data())
                    
                    self.items.append(comment)
                }
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = commentInputAccessoryView.frame
        
        let dummyCell = CommentCell(frame: frame)
        dummyCell.item = self.items[indexPath.item]
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 50) // Any size will work
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        return .init(width: view.frame.width, height: max(40 + 8 * 2, estimatedSize.height))
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.resignFirstResponder()
        
        tabBarController?.tabBar.isHidden = false
        
        self.listener?.remove()
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    
    lazy var commentInputAccessoryView: CommentInputAccessoryView = {
        
        let frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        
        let containerView = CommentInputAccessoryView(frame: frame)
        
        containerView.backgroundColor = .white
        
        containerView.delegate = self
        
        return containerView
    }()
    
    func didSubmit(for comment: String) {
        print("Handling submiting from comment view controller...")
        
        guard let postId = self.post?.id else { return }
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let date = Date().timeIntervalSince1970
        
        Firestore.firestore().collection("comments").document(postId).collection("userComments").addDocument(data: ["text" : comment, "userId" : uid, "creationDate" : date]) { (error) in
            if let err = error {
                print("Failed to add comment: ", err)
                return
            }
            
            print("Add comment successfully")
            
            // Reset textfield
            self.commentInputAccessoryView.clearTextViewAndReturn()
        }
    }
    
    
    override var inputAccessoryView: UIView? {
        return commentInputAccessoryView
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
}






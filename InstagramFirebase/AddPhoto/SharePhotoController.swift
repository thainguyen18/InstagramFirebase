//
//  SharePhotoController.swift
//  InstagramFirebase
//
//  Created by Thai Nguyen on 12/7/19.
//  Copyright © 2019 Thai Nguyen. All rights reserved.
//

import UIKit
import Firebase

class SharePhotoController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(white: 0.9, alpha: 1)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        
        setupImageAndTextViews()
    }
    
    var selectedImage: UIImage? {
        didSet {
            imageView.image = selectedImage
        }
    }
    
    let imageView: UIImageView = {
       let iv = UIImageView()
        iv.backgroundColor = .red
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        
        return iv
    }()
    
    let textView: UITextView = {
       let tv = UITextView()
        tv.backgroundColor = .white
        tv.text = "Some caption text for our photo..."
        tv.font = .systemFont(ofSize: 14)
        tv.textColor = .black
        tv.textAlignment = .left
        tv.clearsOnInsertion = true
        
        return tv
    }()
    
    fileprivate func setupImageAndTextViews() {
        let containerView = UIView()
        containerView.backgroundColor = .white
        
        view.addSubview(containerView)
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 100))
        
        containerView.addSubview(imageView)
        imageView.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: nil, padding: .init(top: 8, left: 8, bottom: 8, right: 0), size: .init(width: 100 - 8 * 2, height: 0))
        
        containerView.addSubview(textView)
        textView.anchor(top: containerView.topAnchor, leading: imageView.trailingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: .init(top: 8, left: 8, bottom: 8, right: 8))
    }
    
    @objc func handleShare() {
        guard let caption = textView.text, caption.count > 0 else {
            print("Please add caption!")
            return
        }
        
        let filename = UUID().uuidString
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        guard let selectedImage = self.selectedImage, let imageData = selectedImage.jpegData(compressionQuality: 0.5) else { return }
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        Storage.storage().reference().child("posts").child(filename).putData(imageData, metadata: metadata) { (metaData, error) in
            if let err = error {
                print("Failed to upload image: ", err)
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                return
            }
            
            guard let path = metaData?.path else { return }
            
            Storage.storage().reference(withPath: path).downloadURL { (url, error) in
                if let err = error {
                    print("Some error: ", err)
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    return
                }
                
                guard let imageUrl = url else { return }
                
                print("Successfully uploaded image: ", imageUrl.absoluteString)
                
                self.saveToDatabaseWithImageUrl(imageUrl: imageUrl.absoluteString)
            }
        }
    }
    
    fileprivate func saveToDatabaseWithImageUrl(imageUrl: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard let postImage = selectedImage else { return }
        
        guard let caption = textView.text else { return }
        
        let userPostRef = Firestore.firestore().collection("posts").document(uid).collection("userposts").document()
        
        let values: [String : Any] = ["imageUrl" : imageUrl, "caption" : caption, "imageWidth" : postImage.size.width, "imageHeight" : postImage.size.height, "creationDate" : Date().timeIntervalSince1970]
        
        userPostRef.setData(values) { (error) in
            if let err = error {
                print("Failed to save post to db: ", err)
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                return
            }
            
            print("Successfully save post to db")
            
            self.dismiss(animated: true)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
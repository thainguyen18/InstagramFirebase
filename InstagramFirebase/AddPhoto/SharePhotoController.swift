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
        
        title = "Create Post"
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.setGradientBackground()
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
        tv.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        tv.text = "Some caption text for our photo..."
        tv.font = .systemFont(ofSize: 14)
        tv.textColor = .black
        tv.textAlignment = .left
        tv.clearsOnInsertion = true
        
        return tv
    }()
    
    fileprivate func setupImageAndTextViews() {
        let containerView = UIView()
        containerView.backgroundColor = UIColor(white: 1.0, alpha: 0.7)
        
        containerView.layer.cornerRadius = 15
        
        view.addSubview(containerView)
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 12, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 100))
        
        containerView.addSubview(imageView)
        imageView.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: nil, padding: .init(top: 8, left: 8, bottom: 8, right: 0), size: .init(width: 100 - 8 * 2, height: 0))
        
        containerView.addSubview(textView)
        textView.anchor(top: containerView.topAnchor, leading: imageView.trailingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: .init(top: 8, left: 8, bottom: 8, right: 8))
    }
    
    @objc func handleShare() {
        guard let caption = textView.text, caption.count > 0 else {
            let alert = UIAlertController(title: "No Caption", message: "Please add caption!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            
            present(alert, animated: true)
            
            return
        }
        
        // This is a long process, add a spinner
        let spinner = UIActivityIndicatorView()
        spinner.style = .whiteLarge
        spinner.hidesWhenStopped = true
        
        view.addSubview(spinner)
        spinner.centerInSuperview()
        
        spinner.startAnimating()
        
        
        // Limit caption text to 160 characters follows Twitter style
        guard textView.text.count <= 160 else {
            
            let alert = UIAlertController(title: "Caption too long", message: "Please limit your caption to 160 characters. Thank you!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            
            present(alert, animated: true)
            
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
                
                spinner.stopAnimating()
                spinner.removeFromSuperview()
                
                return
            }
            
            guard let path = metaData?.path else { return }
            
            Storage.storage().reference(withPath: path).downloadURL { (url, error) in
                if let err = error {
                    print("Some error: ", err)
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    
                    spinner.stopAnimating()
                    spinner.removeFromSuperview()
                    
                    return
                }
                
                guard let imageUrl = url else { return }
                
                print("Successfully uploaded image: ", imageUrl.absoluteString)
                
                // Generate image thumnail and save to Firebase storage-----------------------
                let thumbnailName = UUID().uuidString
                let ratio = selectedImage.size.width / selectedImage.size.height
                let desiredHeight: CGFloat = 100
                let size = CGSize(width: desiredHeight * ratio, height: desiredHeight)
                
                let renderer = UIGraphicsImageRenderer(size: size)
                let thumbnailImage = renderer.image { context in
                    selectedImage.draw(in: CGRect(origin: .zero, size: size))
                }
                guard let thumbnailImageData = thumbnailImage.jpegData(compressionQuality: 0.8) else { return }
                
                Storage.storage().reference().child("posts").child(thumbnailName).putData(thumbnailImageData, metadata: metadata) { (metaData, error) in
                if let err = error {
                    print("Failed to upload image: ", err)
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    
                    spinner.stopAnimating()
                    spinner.removeFromSuperview()
                    
                    return
                }
                
                guard let path = metaData?.path else { return }
                
                Storage.storage().reference(withPath: path).downloadURL { (url, error) in
                    if let err = error {
                        print("Some error: ", err)
                        
                        spinner.stopAnimating()
                        spinner.removeFromSuperview()
                    
                        return
                    }
                    
                    guard let thumbnailImageUrl = url else { return }
                    
                    print("Successfully uploaded thumbnail image: ", thumbnailImageUrl.absoluteString)
                    
                    self.saveToDatabaseWithImageUrl(imageUrl: imageUrl.absoluteString, thumbnailUrl: thumbnailImageUrl.absoluteString)
                    }
                }
                // End thumbnail image processing---------------------------------
                
                //self.saveToDatabaseWithImageUrl(imageUrl: imageUrl.absoluteString)
            }
        }
    }
    
    static let updateFeedNotificationName = Notification.Name("UpdatedFeed")
    
    fileprivate func saveToDatabaseWithImageUrl(imageUrl: String, thumbnailUrl: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard let postImage = selectedImage else { return }
        
        guard let caption = textView.text else { return }
        
        let userPostRef = Firestore.firestore().collection("posts").document()
        
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        
        guard let mainTabBarController =  window?.rootViewController as? MainTabBarController else { return }
        
        guard let location = mainTabBarController.locationFetcher.lastKnownLocation else { return }
        
        let latitude = Double(location.latitude)
        let longitude = Double(location.longitude)
        
        let values: [String : Any] = ["imageUrl" : imageUrl, "caption" : caption, "imageWidth" : postImage.size.width, "imageHeight" : postImage.size.height, "creationDate" : Date().timeIntervalSince1970, "userId": uid, "latitude" : latitude, "longitude" : longitude,
                                      "thumbnailUrl": thumbnailUrl]
        
        userPostRef.setData(values) { (error) in
            if let err = error {
                print("Failed to save post to db: ", err)
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                return
            }
            
            print("Successfully save post to db")
            
            self.dismiss(animated: true)
            
            // Posting notifications to update home feeds
            NotificationCenter.default.post(name: SharePhotoController.updateFeedNotificationName, object: nil)
            
            // Increment number of posts
            self.incrementUserNumberOfPosts()
        }
    }
    
    fileprivate func incrementUserNumberOfPosts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.fetchUserWithUID(uid: uid) { (user) in
            Firestore.firestore().collection("users").document(uid).updateData(["numberOfPosts": user.numberOfPosts + 1]) { (error) in
                if let err = error {
                    print("Failed to increase number of posts: ", err)
                    return
                }
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // Dismiss keyboard upon touching outside textview
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        view.endEditing(true)
    }
}

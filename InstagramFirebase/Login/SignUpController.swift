//
//  ViewController.swift
//  InstagramFirebase
//
//  Created by Thai Nguyen on 12/4/19.
//  Copyright © 2019 Thai Nguyen. All rights reserved.
//

import UIKit
import SwiftUI
import LBTATools
import Firebase

class SignUpController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        
        return button
    }()
    
    @objc func handlePlusPhoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let originalImage = info[.originalImage] as? UIImage {
            plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let edittedImage = info[.editedImage] as? UIImage {
            plusPhotoButton.setImage(edittedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.size.width / 2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.black.cgColor
        plusPhotoButton.layer.borderWidth = 3
        
        // If updating user profile
        if let _ = self.user {
             signupButton.isEnabled = true
             signupButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        }
        
        dismiss(animated: true)
    }
    
    let emailTextField: UITextField = {
        let tf = UITextField(placeholder: "Email")
        tf.backgroundColor = UIColor.init(white: 1.0, alpha: 0.7)
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 14)
        tf.textColor = .black
        
        tf.addTarget(self, action: #selector(handleTextInput), for: .editingChanged)
        return tf
    }()
    
    @objc func handleTextInput() {
        let isFormValid = emailTextField.text?.count ?? 0 > 0 &&
            usernameTextField.text?.count ?? 0 > 0 &&
            passwordTextField.text?.count ?? 0 > 0
        
        if isFormValid {
            signupButton.isEnabled = true
            signupButton.backgroundColor = UIColor.rgb(red: 246, green: 114, blue: 65)
            signupButton.alpha = 1.0
        } else {
            signupButton.isEnabled = false
            signupButton.backgroundColor = UIColor.rgb(red: 244, green: 129, blue: 70)
            signupButton.alpha = 0.7
        }
    }
    
    let usernameTextField: UITextField = {
        let tf = UITextField(placeholder: "Username")
        tf.backgroundColor = UIColor.init(white: 1.0, alpha: 0.7)
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 14)
        tf.textColor = .black
        tf.addTarget(self, action: #selector(handleTextInput), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField(placeholder: "Password")
        tf.backgroundColor = UIColor.init(white: 1.0, alpha: 0.7)
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 14)
        tf.isSecureTextEntry = true
        tf.textColor = .black
        tf.addTarget(self, action: #selector(handleTextInput), for: .editingChanged)
        return tf
    }()
    
    let signupButton: UIButton = {
        let button = UIButton(title: "Sign Up", titleColor: .white, font: .boldSystemFont(ofSize: 14), backgroundColor: UIColor.rgb(red: 244, green: 129, blue: 70))
        button.alpha = 0.7
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.layer.cornerRadius = 5
        
        button.isEnabled = false
        
        return button
    }()
    
    let alreadyHaveAnAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor.black])
        
        attributedTitle.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor.white]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleAlreadyHaveAnAccount), for: .touchUpInside)
        return button
    }()
    
    @objc func handleAlreadyHaveAnAccount() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    fileprivate func updateEmail(with email: String) {
        Auth.auth().currentUser?.updateEmail(to: email, completion: nil)
    }
    
    fileprivate func updatePassword(with password: String) {
        Auth.auth().currentUser?.updatePassword(to: password, completion: nil)
    }
    
    fileprivate func updateProfileImageUrl() {
        // Upload user profile image
        guard let image = self.plusPhotoButton.imageView?.image else { return }
        
        guard let imageData = image.jpegData(compressionQuality: 0.3) else { return }
        
        let fileName = UUID().uuidString
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        Storage.storage().reference().child("profile_images").child(fileName).putData(imageData, metadata: metaData) { (metaData, error) in
            if let err = error {
                print("Failed to upload profile image: ", err)
                return
            }
            
            guard let path = metaData?.path else { return }
            
            Storage.storage().reference(withPath: path).downloadURL(completion: { (url, error) in
                if let err = error {
                    print("Some error: ", err)
                    return
                }
                
                guard let profileImageUrl = url else { return }
                
                print("Successfully uploaded profile image", profileImageUrl.absoluteString)
                
                // User database
                guard let uid = Auth.auth().currentUser?.uid else { return }
                
                Firestore.firestore().collection("users").document(uid).updateData(
                    ["profileImageUrl": profileImageUrl.absoluteString],
                    completion: { (err) in
                        if let err = err {
                            print("Failed to update user info into db: ", err)
                            return
                        }
                        
                        print("Successfully updated user info into db")
                        
                        NotificationCenter.default.post(name: SignUpController.profileUpdateNotificationName, object: nil)
                        
                        self.dismiss(animated: true)
//
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                            guard let mainTabController = self.presentingViewController as? MainTabBarController else { return }
//                            guard let upvc = mainTabController.viewControllers?.last as? UserProfileController else { return }
//
//                            upvc.collectionView.reloadData()
//                        }
                })
            })
        }
    }
    
    static let profileUpdateNotificationName = Notification.Name("profileUpdate")
    
    
    @objc func handleSignUp() {
        guard let email = emailTextField.text, email.count > 0 else { return }
        guard let username = usernameTextField.text, username.count > 0 else { return }
        guard let password = passwordTextField.text, password.count > 0 else { return }
        
        
        let spinner = UIActivityIndicatorView()
        spinner.style = .whiteLarge
        spinner.hidesWhenStopped = true
        
        self.view.addSubview(spinner)
        spinner.centerXToSuperview()
        spinner.anchor(top: signupButton.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 16, left: 0, bottom: 0, right: 0))
        
        spinner.startAnimating()
        
        // Handle updating profile if in such case
        if self.signupButton.titleLabel?.text == "Update" {
            print("Handle updating...")
            
            updateEmail(with: email)
            updatePassword(with: password)
            updateProfileImageUrl()
            
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (result: AuthDataResult?, error: Error?) in
            if let err = error {
                print("Failed to create user", err)
                
                spinner.stopAnimating()
                spinner.removeFromSuperview()
                
                let alert = UIAlertController(title: "Error! Failed to sign up", message: "Please try again later.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                
                return
            }
            
            print("Successfully created user: ", result?.user.uid ?? "")
            
            
            // Upload user profile image
            guard let image = self.plusPhotoButton.imageView?.image else { return }
            
            guard let imageData = image.jpegData(compressionQuality: 0.3) else { return }
            
            let fileName = UUID().uuidString
            
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            
            Storage.storage().reference().child("profile_images").child(fileName).putData(imageData, metadata: metaData) { (metaData, error) in
                if let err = error {
                    print("Failed to upload profile image: ", err)
                    
                    spinner.stopAnimating()
                    spinner.removeFromSuperview()
                    
                    return
                }
                
                guard let path = metaData?.path else { return }
                
                Storage.storage().reference(withPath: path).downloadURL(completion: { (url, error) in
                    if let err = error {
                        print("Some error: ", err)
                        
                        spinner.stopAnimating()
                        spinner.removeFromSuperview()
                        
                        return
                    }
                    
                    guard let profileImageUrl = url else { return }
                    
                    print("Successfully uploaded profile image", profileImageUrl.absoluteString)
                    
                    // User database
                    guard let uid = result?.user.uid else { return }
                    guard let username = self.usernameTextField.text else { return }
                    guard let fcmToken = Messaging.messaging().fcmToken else { return }
                    
                    Firestore.firestore().collection("users").document(uid).setData(
                        ["username": username,
                         "profileImageUrl": profileImageUrl.absoluteString,
                         "fcmToken": fcmToken,
                         "numberOfPosts": 0],
                        completion: { (err) in
                        if let err = err {
                            print("Failed to save user info into db: ", err)
                            
                            spinner.stopAnimating()
                            spinner.removeFromSuperview()
                            
                            return
                        }
                        
                        print("Successfully saved user info into db")
                        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                            
                        guard let mainTabBarController = window?.rootViewController as? MainTabBarController else { return }
                            
                        mainTabBarController.setupViewControllers()
                            
                        self.dismiss(animated: true)
                    })
                })
            }
            
        }
    }
    
    
    // Using this property when user edits their profile
    var user: User?
    var password: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //view.backgroundColor = .white
        
        view.setGradientBackground()
        
        view.addSubview(plusPhotoButton)
        
        plusPhotoButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 40, left: 0, bottom: 0, right: 0), size: .init(width: 150, height: 150))
        
        plusPhotoButton.centerXToSuperview()
        
        setUpInputFields()
        
        view.addSubview(alreadyHaveAnAccountButton)
        
        alreadyHaveAnAccountButton.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 40))
        
        // If updating user profile
        if let _ = self.user {
            setupUpdateMode()
        }
    }
    
    fileprivate func setupUpdateMode() {
        
        guard let userAuth = Auth.auth().currentUser else { return }
        
        self.alreadyHaveAnAccountButton.isHidden = true
        
        self.signupButton.setTitle("Update", for: .normal)
        
        self.usernameTextField.isEnabled = false
        
        self.emailTextField.text = userAuth.email
        
        self.passwordTextField.text = password
        
        guard let userDatabase = self.user else { return }
        
        self.usernameTextField.text = userDatabase.username
        
        
        // Enable update button
        self.handleTextInput()
        
        guard let url = URL(string: userDatabase.profileImageUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let err = error {
                print("Failed to fetch user image: ", err)
                return
            }
            
            guard let data = data else { return }
            
            let photoImage = UIImage(data: data)
            
            DispatchQueue.main.async {
                self.plusPhotoButton.setImage(photoImage?.withRenderingMode(.alwaysOriginal), for: .normal)
                self.plusPhotoButton.layer.cornerRadius = self.plusPhotoButton.frame.width / 2
                self.plusPhotoButton.layer.masksToBounds = true
                self.plusPhotoButton.layer.borderColor = UIColor.black.cgColor
                self.plusPhotoButton.layer.borderWidth = 3
            }
        }.resume()
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        self.view.endEditing(true)
    }
    
    
    fileprivate func setUpInputFields() {
        let stackViews = UIStackView(arrangedSubviews: [emailTextField, usernameTextField, passwordTextField, signupButton])
        stackViews.axis = .vertical
        stackViews.alignment = .fill
        stackViews.distribution = .fillEqually
        stackViews.spacing = 10
        
        view.addSubview(stackViews)
        
        stackViews.anchor(top: plusPhotoButton.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 20, left: 40, bottom: 0, right: 40), size: .init(width: 0, height: 200))
    }
}



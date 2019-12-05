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

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
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
        
        dismiss(animated: true)
    }
    
    let emailTextField: UITextField = {
        let tf = UITextField(placeholder: "Email")
        tf.backgroundColor = UIColor.init(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 14)
        
        tf.addTarget(self, action: #selector(handleTextInput), for: .editingChanged)
        return tf
    }()
    
    @objc func handleTextInput() {
        let isFormValid = emailTextField.text?.count ?? 0 > 0 &&
            usernameTextField.text?.count ?? 0 > 0 &&
            passwordTextField.text?.count ?? 0 > 0
        
        if isFormValid {
            signupButton.isEnabled = true
            signupButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        } else {
            signupButton.isEnabled = false
            signupButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }
    
    let usernameTextField: UITextField = {
        let tf = UITextField(placeholder: "Username")
        tf.backgroundColor = UIColor.init(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInput), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField(placeholder: "Password")
        tf.backgroundColor = UIColor.init(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 14)
        tf.isSecureTextEntry = true
        tf.addTarget(self, action: #selector(handleTextInput), for: .editingChanged)
        return tf
    }()
    
    let signupButton: UIButton = {
        let button = UIButton(title: "Sign Up", titleColor: .white, font: .boldSystemFont(ofSize: 14), backgroundColor: UIColor.rgb(red: 149, green: 204, blue: 244))
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.layer.cornerRadius = 5
        
        button.isEnabled = false
        
        return button
    }()
    
    
    @objc func handleSignUp() {
        guard let email = emailTextField.text, email.count > 0 else { return }
        guard let username = usernameTextField.text, username.count > 0 else { return }
        guard let password = passwordTextField.text, password.count > 0 else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (result: AuthDataResult?, error: Error?) in
            if let err = error {
                print("Failed to create user", err)
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
                    guard let uid = result?.user.uid else { return }
                    guard let username = self.usernameTextField.text else { return }
                    
                    Firestore.firestore().collection("users").document(uid).setData(
                        ["username": username,
                         "profileImageUrl": profileImageUrl.absoluteString],
                        completion: { (err) in
                        if let err = err {
                            print("Failed to save user info into db: ", err)
                            return
                        }
                        
                        print("Successfully saved user info into db")
                    })
                })
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(plusPhotoButton)
        
        plusPhotoButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 40, left: 0, bottom: 0, right: 0), size: .init(width: 140, height: 140))
        
        plusPhotoButton.centerXToSuperview()
        
        
        setUpInputFields()
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

struct ViewControllerPreview: PreviewProvider {
    static var previews: some View {
        ViewControllerContainerView()
    }
    
    struct ViewControllerContainerView: UIViewControllerRepresentable {
        func updateUIViewController(_ uiViewController: ViewControllerPreview.ViewControllerContainerView.UIViewControllerType, context: UIViewControllerRepresentableContext<ViewControllerPreview.ViewControllerContainerView>) {
            
        }
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<ViewControllerPreview.ViewControllerContainerView>) -> ViewController {
            return ViewController()
        }
    }
}

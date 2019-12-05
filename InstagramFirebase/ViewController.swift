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

class ViewController: UIViewController {
    
    let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        
        return button
    }()
    
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

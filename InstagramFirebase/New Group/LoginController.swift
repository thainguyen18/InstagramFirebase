//
//  LoginController.swift
//  InstagramFirebase
//
//  Created by Thai Nguyen on 12/5/19.
//  Copyright © 2019 Thai Nguyen. All rights reserved.
//

import UIKit
import SwiftUI
import LBTATools
import Firebase

class LoginController: UIViewController {
    let dontHaveAnAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account?  ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor.rgb(red: 17, green: 154, blue: 237)]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
    @objc func handleShowSignUp() {
        let signUpController = SignUpController()
        navigationController?.pushViewController(signUpController, animated: true)
        
    }
    
    let emailTextField: UITextField = {
        let tf = UITextField(placeholder: "Email")
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
    
    @objc func handleTextInput() {
           let isFormValid = emailTextField.text?.count ?? 0 > 0 &&
               passwordTextField.text?.count ?? 0 > 0
           
           if isFormValid {
               loginButton.isEnabled = true
               loginButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
           } else {
               loginButton.isEnabled = false
               loginButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
           }
       }
    
    let loginButton: UIButton = {
        let button = UIButton(title: "Log In", titleColor: .white, font: .boldSystemFont(ofSize: 14), backgroundColor: UIColor.rgb(red: 149, green: 204, blue: 244))
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        button.layer.cornerRadius = 5
        
        button.isEnabled = false
        
        return button
    }()
    
    @objc func handleLogin() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            if let err = error {
                print("Failed to log in: ", err)
                return
            }
            
            print("Successfully logged back in with user: ", authDataResult?.user.uid ?? "")
            
            guard let mainTabBarController = self.presentingViewController as? MainTabBarController else { return }
            
            mainTabBarController.setupViewControllers()
            
            self.dismiss(animated: true)
        }
    }
    
    let logoContainer: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.rgb(red: 0, green: 120, blue: 175)
        
        let logo = UIImageView(image: #imageLiteral(resourceName: "Instagram_logo_white"), contentMode: .scaleAspectFill)
        
        view.addSubview(logo)
        
        logo.centerInSuperview()
        
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationController?.isNavigationBarHidden = true
        
        setupForm()
    }
    
    fileprivate func setupForm() {
        view.addSubview(dontHaveAnAccountButton)
        
        dontHaveAnAccountButton.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 40))
        
        view.addSubview(logoContainer)
        
        logoContainer.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 150))
        
        let stackViews = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
        stackViews.axis = .vertical
        stackViews.alignment = .fill
        stackViews.distribution = .fillEqually
        stackViews.spacing = 10
        
        view.addSubview(stackViews)
        
        stackViews.anchor(top: logoContainer.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 40, left: 40, bottom: 0, right: 40), size: .init(width: 0, height: 150))
    }
}

struct LoginControllerPreview: PreviewProvider {
    static var previews: some View {
        LoginView().edgesIgnoringSafeArea(.all)
    }
    
    
    struct LoginView: UIViewControllerRepresentable {
        func updateUIViewController(_ uiViewController: LoginControllerPreview.LoginView.UIViewControllerType, context: UIViewControllerRepresentableContext<LoginControllerPreview.LoginView>) {
            
        }
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<LoginControllerPreview.LoginView>) -> LoginController {
            return LoginController()
        }
    }
}

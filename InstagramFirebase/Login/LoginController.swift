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
        
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account?  ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor.black])
        
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor.white]))
        
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
        tf.textColor = .black
        tf.isSecureTextEntry = true
        tf.addTarget(self, action: #selector(handleTextInput), for: .editingChanged)
        return tf
    }()
    
    @objc func handleTextInput() {
           let isFormValid = emailTextField.text?.count ?? 0 > 0 &&
               passwordTextField.text?.count ?? 0 > 0
           
           if isFormValid {
               loginButton.isEnabled = true
               loginButton.backgroundColor = UIColor.rgb(red: 246, green: 114, blue: 65)
               loginButton.alpha = 1.0
           } else {
               loginButton.isEnabled = false
               loginButton.backgroundColor = UIColor.rgb(red: 244, green: 129, blue: 70)
               loginButton.alpha = 0.7
           }
       }
    
    let loginButton: UIButton = {
        let button = UIButton(title: "Log In", titleColor: .white, font: .boldSystemFont(ofSize: 14), backgroundColor: UIColor.rgb(red: 244, green: 129, blue: 70))
        button.alpha = 0.7
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
                
                let alert = UIAlertController(title: "Failed to log in", message: "Please check your email/password.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                
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
        view.backgroundColor = .clear //UIColor.rgb(red: 0, green: 120, blue: 175)
        
        let logo = UIImageView(image: #imageLiteral(resourceName: "Instaminimalist_white").withRenderingMode(.alwaysOriginal), contentMode: .scaleAspectFill)
        
        view.addSubview(logo)
        
        logo.centerInSuperview()
        
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.backgroundColor = .white
        
        view.setGradientBackground()
        
        navigationController?.isNavigationBarHidden = true
        
        setupForm()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        self.view.endEditing(true)
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


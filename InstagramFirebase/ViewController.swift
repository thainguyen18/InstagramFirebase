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
        return tf
    }()
    
    let usernameTextField: UITextField = {
        let tf = UITextField(placeholder: "Username")
        tf.backgroundColor = UIColor.init(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 14)
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField(placeholder: "Password")
        tf.backgroundColor = UIColor.init(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 14)
        tf.isSecureTextEntry = true
        return tf
    }()
    
    let signupButton: UIButton = {
        let button = UIButton(title: "Sign Up", titleColor: .white, font: .boldSystemFont(ofSize: 14), backgroundColor: UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1))
        
        button.layer.cornerRadius = 5
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(plusPhotoButton)
        
        plusPhotoButton.withSize(.init(width: 140, height: 140))
        plusPhotoButton.centerXToSuperview()
        plusPhotoButton.anchor(.top(view.safeAreaLayoutGuide.topAnchor, constant: 40))
        
        setUpInputFields()
    }
    
    fileprivate func setUpInputFields() {
        let stackViews = UIStackView(arrangedSubviews: [emailTextField, usernameTextField, passwordTextField, signupButton])
        stackViews.axis = .vertical
        stackViews.alignment = .fill
        stackViews.distribution = .fillEqually
        stackViews.spacing = 10
        
        view.addSubview(stackViews)
        
        stackViews.anchor(top: plusPhotoButton.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 20, left: 40, bottom: 0, right: 40), size: .init(width: 0, height: 50 * 4 + 10 * 3))
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

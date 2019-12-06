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

class LoginController: UIViewController {
    let signupButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Don't have an account? Sign Up", for: .normal)
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
    @objc func handleShowSignUp() {
        let signUpController = SignUpController()
        navigationController?.pushViewController(signUpController, animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationController?.isNavigationBarHidden = true
        
        view.addSubview(signupButton)
        
        signupButton.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 20))
    }
}

struct LoginControllerPreview: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
    
    
    struct LoginView: UIViewControllerRepresentable {
        func updateUIViewController(_ uiViewController: LoginControllerPreview.LoginView.UIViewControllerType, context: UIViewControllerRepresentableContext<LoginControllerPreview.LoginView>) {
            
        }
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<LoginControllerPreview.LoginView>) -> LoginController {
            return LoginController()
        }
    }
}

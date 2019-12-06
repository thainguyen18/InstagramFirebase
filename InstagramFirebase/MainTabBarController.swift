//
//  MainTabBarController.swift
//  InstagramFirebase
//
//  Created by Thai Nguyen on 12/5/19.
//  Copyright © 2019 Thai Nguyen. All rights reserved.
//

import UIKit
import SwiftUI
import Firebase

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewControllers()
    }
    
    func setupViewControllers() {
        let userProfileController = UserProfileController()
        
        let nav = UINavigationController(rootViewController: userProfileController)
        
        nav.tabBarItem.image = #imageLiteral(resourceName: "profile_unselected")
        nav.tabBarItem.selectedImage = #imageLiteral(resourceName: "profile_selected")
        
        tabBar.tintColor = .black
        viewControllers = [nav, UIViewController()]
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showLogIn()
    }
    
    fileprivate func showLogIn() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let loginController = LoginController()
                let nav = UINavigationController(rootViewController: loginController)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            }
        }
    }
}

struct MainTabBarControllerPreview: PreviewProvider {
    static var previews: some View {
        MainTabBarViewContainer().edgesIgnoringSafeArea(.all)
    }
    
    struct MainTabBarViewContainer: UIViewControllerRepresentable {
        func updateUIViewController(_ uiViewController: MainTabBarControllerPreview.MainTabBarViewContainer.UIViewControllerType, context: UIViewControllerRepresentableContext<MainTabBarControllerPreview.MainTabBarViewContainer>) {
            
        }
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<MainTabBarControllerPreview.MainTabBarViewContainer>) -> MainTabBarController {
            return MainTabBarController()
        }
    }
}

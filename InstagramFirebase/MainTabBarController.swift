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

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        setupViewControllers()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let index = viewControllers?.firstIndex(of: viewController)
        
        if index == 2 {
            
            let photoSelectorController = PhotoSelectorController()
            let nav = UINavigationController(rootViewController: photoSelectorController)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
            
            return false
        }
        
        return true
    }
    
    func setupViewControllers() {
        // Home
        let homeNav = templateNav(selectedImage: #imageLiteral(resourceName: "home_selected"), unselectedImage: #imageLiteral(resourceName: "home_unselected"), rootViewController: HomeController())
        
        // Search
        let searchNav = templateNav(selectedImage: #imageLiteral(resourceName: "search_selected"), unselectedImage: #imageLiteral(resourceName: "search_unselected"), rootViewController: SearchController())
        
        // Plus
        let plusNav = templateNav(selectedImage: #imageLiteral(resourceName: "plus_unselected") , unselectedImage: #imageLiteral(resourceName: "plus_unselected"))
        
        // Like
        let likeNav = templateNav(selectedImage: #imageLiteral(resourceName: "like_selected"), unselectedImage: #imageLiteral(resourceName: "like_unselected"), rootViewController: LikeController())
        
        // user profile
        let profileNav = templateNav(selectedImage: #imageLiteral(resourceName: "profile_selected"), unselectedImage: #imageLiteral(resourceName: "profile_unselected"), rootViewController: UserProfileController())
        
        // add view controllers to tab bar
        tabBar.tintColor = .black
        viewControllers = [homeNav, searchNav, plusNav, likeNav, profileNav]
        
        // Modify tab bar items insets
        tabBar.items?.forEach {
            $0.imageInsets = .init(top: 4, left: 0, bottom: -4, right: 0)
        }
    }
    
    fileprivate func templateNav(selectedImage: UIImage, unselectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let viewController = rootViewController
        let nav = UINavigationController(rootViewController: viewController)
        
        nav.tabBarItem.image = unselectedImage
        nav.tabBarItem.selectedImage = selectedImage
        
        return nav
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

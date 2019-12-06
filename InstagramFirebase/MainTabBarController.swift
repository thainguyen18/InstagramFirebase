//
//  MainTabBarController.swift
//  InstagramFirebase
//
//  Created by Thai Nguyen on 12/5/19.
//  Copyright © 2019 Thai Nguyen. All rights reserved.
//

import UIKit
import SwiftUI

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userProfileController = UserProfileController()
        
        let nav = UINavigationController(rootViewController: userProfileController)
        
        nav.tabBarItem.image = #imageLiteral(resourceName: "profile_unselected")
        nav.tabBarItem.selectedImage = #imageLiteral(resourceName: "profile_selected")
        
        tabBar.tintColor = .black
        
        viewControllers = [nav, UIViewController()]
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

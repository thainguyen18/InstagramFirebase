//
//  CustomImageView.swift
//  InstagramFirebase
//
//  Created by Thai Nguyen on 12/7/19.
//  Copyright © 2019 Thai Nguyen. All rights reserved.
//

import UIKit

var imageCache = [String : UIImage]()

class CustomImageView: UIImageView {
    
    private var lastUsedUrl: String?
    
    func loadImage(urlString: String) {
        
        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage
            return
        }
        
        if lastUsedUrl == urlString { return }
        
        lastUsedUrl = urlString
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let err = error {
                print("Failed to fetch post image: ", err)
                return
            }
            
            guard let data = data else { return }
            
            let photoImage = UIImage(data: data)
            
            imageCache[urlString] = photoImage
            
            DispatchQueue.main.async {
                self.image = photoImage
            }
        }.resume()
        
        print("loading image...")
    }
}

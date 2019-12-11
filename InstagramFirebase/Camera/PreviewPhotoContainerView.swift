//
//  PreviewPhotoContainerView.swift
//  InstagramFirebase
//
//  Created by Thai Nguyen on 12/10/19.
//  Copyright © 2019 Thai Nguyen. All rights reserved.
//

import UIKit
import Photos
import LBTATools

class PreviewPhotoContainerView: UIView {
    
    let saveButton: UIButton = {
       let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "save_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return button
    }()
    
    @objc func handleSave() {
        let library = PHPhotoLibrary.shared()
        
        guard let image = self.previewImageView.image else { return }
        
        library.performChanges({
           
          PHAssetChangeRequest.creationRequestForAsset(from: image)
        
        }) { (success, error) in
            if let err = error {
                print("Failed to save photo: ", err)
                return
            }
                
            print("Successfully saved image to library!")
            
            DispatchQueue.main.async {
                let savedLabel = UILabel()
                savedLabel.text = "Saved successfully"
                savedLabel.textColor = .white
                savedLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
                savedLabel.numberOfLines = 0
                savedLabel.layer.cornerRadius = 15
                savedLabel.font = .boldSystemFont(ofSize: 18)
                savedLabel.textAlignment = .center
                
                self.addSubview(savedLabel)
                
                savedLabel.centerInSuperview()
                savedLabel.withSize(.init(width: 150, height: 80))
                
            
                savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
                
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
                }) { (completed) in
                    // completed
                    
                    UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                        
                        savedLabel.layer.transform = CATransform3DMakeScale(0.01, 0.01, 0.01)
                        savedLabel.alpha = 0
                        
                    }) { (_) in
                        
                        savedLabel.removeFromSuperview()
                        self.handleCancel()
                    }
                }
            }
        }
    }
    
    let cancelButton: UIButton = {
       let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "cancel_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    @objc func handleCancel() {
        self.removeFromSuperview()
    }
    
    let previewImageView: UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(previewImageView)
        previewImageView.fillSuperview()
        
        addSubview(cancelButton)
        cancelButton.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 12, left: 12, bottom: 0, right: 0), size: .init(width: 50, height: 50))
        
        addSubview(saveButton)
        saveButton.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: nil, padding: .init(top: 0, left: 12, bottom: 12, right: 0), size: .init(width: 50, height: 50))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  CommentInputTextView.swift
//  InstagramFirebase
//
//  Created by Thai Nguyen on 12/20/19.
//  Copyright © 2019 Thai Nguyen. All rights reserved.
//

import UIKit

class CommentInputTextView: UITextView {
    
    private let placeHolderLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter comment"
        label.textColor = .lightGray
        
        return label
    }()
    
    func showPlaceHolder() {
        placeHolderLabel.isHidden = false
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextChange), name: UITextView.textDidChangeNotification, object: nil)
        
        addSubview(placeHolderLabel)
        placeHolderLabel.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 8, left: 8, bottom: 0, right: 0))
    }
    
    @objc fileprivate func handleTextChange() {
        self.placeHolderLabel.isHidden = !self.text.isEmpty
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

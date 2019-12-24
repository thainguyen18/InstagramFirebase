//
//  CommentInputAccessoryView.swift
//  InstagramFirebase
//
//  Created by Thai Nguyen on 12/20/19.
//  Copyright © 2019 Thai Nguyen. All rights reserved.
//

import UIKit

protocol CommentInputAccessoryViewDelegate {
    func didSubmit(for comment: String)
}

class CommentInputAccessoryView: UIView {
    
    override var intrinsicContentSize: CGSize {
        return CGSize.zero
    }
    
    var delegate: CommentInputAccessoryViewDelegate?
    
    
    fileprivate let submitButton: UIButton = {
        
        let sb = UIButton(type: .system)
        sb.setTitle("Submit", for: .normal)
        sb.setTitleColor(.black, for: .normal)
        sb.titleLabel?.font = .boldSystemFont(ofSize: 14)
        sb.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        
        return sb
    }()
    
    let commentTextView: CommentInputTextView = {
       let tv = CommentInputTextView()
        
        tv.font = .systemFont(ofSize: 18)
        
        tv.isScrollEnabled = false
        
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        autoresizingMask = .flexibleHeight
        
        setupSubmitButton()
        
        setupTextView()
        
        setupSeparatorView()
    }
    
    
    fileprivate func setupSubmitButton() {
        addSubview(submitButton)
        submitButton.anchor(top: topAnchor, leading: nil, bottom: nil, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 12), size: .init(width: 50, height: 50))
    }
    
    fileprivate func setupTextView() {
        addSubview(commentTextView)
        commentTextView.anchor(top: topAnchor, leading: leadingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, trailing: submitButton.leadingAnchor, padding: .init(top: 0, left: 8, bottom: 0, right: 0), size: .init(width: 0, height: 0))
    }
    
    fileprivate func setupSeparatorView() {
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        addSubview(separatorView)
        separatorView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 0.5))
    }
    
    @objc private func handleSubmit() {
        
        guard let comment = commentTextView.text, !comment.isEmpty else { return }
        
        self.delegate?.didSubmit(for: comment)
    }
    
    func clearTextViewAndReturn() {
        self.commentTextView.text = nil
        
        self.commentTextView.resignFirstResponder()
        
        // Restore placeholder text
        self.commentTextView.showPlaceHolder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  Extensions.swift
//  InstagramFirebase
//
//  Created by Thai Nguyen on 12/4/19.
//  Copyright © 2019 Thai Nguyen. All rights reserved.
//

import UIKit

extension Date {
    func timeAgoDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        
        let quotient: Int
        let unit: String
        if secondsAgo < minute {
            quotient = secondsAgo
            unit = "second"
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "min"
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "hour"
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "day"
        } else if secondsAgo < month {
            quotient = secondsAgo / week
            unit = "week"
        } else {
            quotient = secondsAgo / month
            unit = "month"
        }
        
        return "\(quotient) \(unit)\(quotient == 1 ? "" : "s") ago"
        
    }
}

extension UIColor {
    static func mainBlue() -> UIColor {
        return UIColor.rgb(red: 17, green: 154, blue: 237)
    }
}

extension UIView {
    func setGradientBackground() {
        let colorTop =  UIColor(red: 14.0/255.0, green: 201.0/255.0, blue: 176.0/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 34.0/255.0, green: 165.0/255.0, blue: 251.0/255.0, alpha: 1.0).cgColor

        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.colors = [colorTop, colorBottom]
        
        gradientLayer.frame = self.bounds

        self.layer.insertSublayer(gradientLayer, at:0)
    }
}

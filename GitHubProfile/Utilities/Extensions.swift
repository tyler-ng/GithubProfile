//
//  Extensions.swift
//  InterviewAssessment
//
//  Created by Ty Nguyen on 2022-01-12.
//

import UIKit

extension UIView {
    class func instanceFromNib(nibView: String) -> UIView {
        return UINib(nibName: nibView, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
}

extension UIImageView {
    func makeRounded() {
        self.layer.masksToBounds = false
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
}

extension String {
    var persistantHash: Int {
        return self.utf8.reduce(5381) {
            ($0 << 5) &+ $0 &+ Int($1)
        }
    }
}

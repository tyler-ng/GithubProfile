//
//  UserProfileView.swift
//  InterviewAssessment
//
//  Created by Ty Nguyen on 2022-01-12.
//

import UIKit
import SkeletonView

class UserProfileView: UIView {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var separateVerticalLine: UIView!
    
    weak var showFollowersViewDelegate: ShowFollowersViewDelegate?
    weak var showFollowingViewDelegate: ShowFollowingViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // clear sample text
        descriptionTextView.text = ""
        
        // remove the margin/padding of UITextView object
        descriptionTextView.textContainer.lineFragmentPadding = 0
        descriptionTextView.textContainerInset = .zero
        
        // make avatar image corners rounded
        avatarImageView.makeRounded()
        
        // customize font for text components
        usernameLabel.font = UIFont(name: "ArialRoundedMTBold", size: 20.0)
        nameLabel.font = UIFont(name: "ArialRoundedMT", size: 18.0)
        followersLabel.font = UIFont(name: "ArialRoundedMTBold", size: 20.0)
        followingLabel.font = UIFont(name: "ArialRoundedMTBold", size: 20.0)
        followersCountLabel.font = UIFont(name: "ArialRoundedMTBold", size: 23.0)
        followingCountLabel.font = UIFont(name: "ArialRoundedMTBold", size: 23.0)
        aboutLabel.font = UIFont(name: "ArialRoundedMTBold", size: 23.0)
        descriptionTextView.font = UIFont(name: "ArialMT", size: 18.0)
        
        // make labels are tapable
        followersCountLabel.isUserInteractionEnabled = true
        followingCountLabel.isUserInteractionEnabled = true
        
        // create and add guesture tap action to followers/following label
        let tapActionForFollowers = UITapGestureRecognizer(target: self, action: #selector(followersLabelWasTapped(sender: )))
        let tapActionForFollowing = UITapGestureRecognizer(target: self, action: #selector(followingLabelWasTapped(sender:)))
        followersCountLabel.addGestureRecognizer(tapActionForFollowers)
        followingCountLabel.addGestureRecognizer(tapActionForFollowing)
        
        // show skeleton by default
        showSkeleton()
    }
    
    @objc func followersLabelWasTapped(sender: UITapGestureRecognizer) {
        self.showFollowersViewDelegate?.showFollowersView()
    }
                                                           
    @objc func followingLabelWasTapped(sender: UITapGestureRecognizer) {
        self.showFollowingViewDelegate?.showFollowingView()
    }
    
    func showSkeleton() {
        // loop through all UI objects to enable its skeleton attribute
        [avatarImageView,
         usernameLabel,
         nameLabel,
         followersLabel,
         followingLabel,
         followersCountLabel,
         followingCountLabel,
         aboutLabel,
         descriptionTextView,
         separateVerticalLine].forEach {
            $0?.isSkeletonable = true
            $0?.showAnimatedGradientSkeleton()
        }
    }
    
    func hideSkeleton() {
        // loop through all UI objects to enable its skeleton attribute
        [avatarImageView,
         usernameLabel,
         nameLabel,
         followersLabel,
         followingLabel,
         followersCountLabel,
         followingCountLabel,
         aboutLabel,
         descriptionTextView,
         separateVerticalLine].forEach {
            $0?.hideSkeleton()
        }
    }
    
}

protocol ShowFollowersViewDelegate: AnyObject {
    func showFollowersView()
}

protocol ShowFollowingViewDelegate: AnyObject {
    func showFollowingView()
}

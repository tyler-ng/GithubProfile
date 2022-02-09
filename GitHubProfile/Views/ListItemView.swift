//
//  ListItemView.swift
//  InterviewAssessment
//
//  Created by Ty Nguyen on 2022-01-12.
//

import UIKit
import SkeletonView

class ListItemView: UITableViewCell {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.makeRounded()
        
        // show skeleton by default
        showSkeleton()
        
    }
    
    func showSkeleton() {
        [avatarImageView, usernameLabel].forEach {
            $0?.isSkeletonable = true
            $0?.showAnimatedGradientSkeleton()
        }
    }
    
    func hideSkeleton() {
        [avatarImageView, usernameLabel].forEach {
            $0?.hideSkeleton()
        }
    }
}

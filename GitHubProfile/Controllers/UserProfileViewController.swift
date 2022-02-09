//
//  UserProfileViewController.swift
//  InterviewAssessment
//
//  Created by Ty Nguyen on 2022-01-12.
//

import UIKit

class UserProfileViewController: UIViewController {
    @IBOutlet weak var mainView: UIView!
    
    private let viewModel = ViewModel()
    private var error: OpenNewError?
    private var userProfile: UserProfile?
    var username: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // make sure username's value is not nil before going furthers
        guard let username = username else {
            return
        }
        // init user profile data
        viewModel.findUserProfileByUsername(username)
    
        // set text for UI navigation title
        self.title = "Profile"
        
        // load a Xib view
        let userProfileView = UIView.instanceFromNib(nibView: "UserProfileView") as! UserProfileView
        
        // add the userProfileView subview to the view stack
        self.mainView.addSubview(userProfileView)
        userProfileView.frame = userProfileView.superview!.bounds
        
        // update value of error variable after data fetching has done
        viewModel.errorStore.bind { [weak self] error in
            guard let error = error else {
                return
            }
            self?.error = error
            
            if error == OpenNewError.userNotFound {
                // remove a view instance of UserProfileView out of mainview
                userProfileView.removeFromSuperview()
                
                // init an instance of UserNotFoundView if any user profile not found
                let userNotFoundView = UIView.instanceFromNib(nibView: "UserNotFoundView") as! UserNotFoundView
                
                // add a view instance to its superview
                self?.mainView.addSubview(userNotFoundView)
                
                // make the subview frame in line with its superview
                userNotFoundView.frame = userNotFoundView.superview!.bounds
            }
        }
        
        // update value of userProfile variable after data fetching has done
        viewModel.userProfileStore.bind { [weak self] userProfile in
            guard let userProfile = userProfile else {
                return
            }
            self?.userProfile = userProfile
            
            // update UI component with new data
            self?.updateUI(userProfileView, userProfile);
        }
    }
    
    func updateUI(_ subView: UIView, _ userProfile: UserProfile) {
        guard let userProfileView = subView as? UserProfileView else { return }
        
        // hide the skeleton
        userProfileView.hideSkeleton()
        
        // check the validation of a image URL before rendering with Kingfisher
        if URLHandler.verifyURL(userProfile.avatar_url) {
            let avatarURL = URL(string: userProfile.avatar_url!)
            userProfileView.avatarImageView.kf.setImage(with: avatarURL!)
        }
        
        // update value for UI components of the userProfileView object
        userProfileView.usernameLabel.text = userProfile.username
        userProfileView.nameLabel.text = userProfile.name
        userProfileView.followersCountLabel.text = "\(userProfile.followers)"
        userProfileView.followingCountLabel.text = "\(userProfile.following)"
        
        // if a found user has defined a description
        if let description = userProfile.description, description.count > 0 {
            userProfileView.descriptionTextView.text = description
        } else {
            let notFoundText = "About content not found"
            userProfileView.descriptionTextView.text = notFoundText
        }
    }
    
}

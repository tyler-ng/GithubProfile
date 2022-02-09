//
//  ViewController.swift
//  InterviewAssessment
//
//  Created by Ty Nguyen on 2022-01-11.
//

import UIKit
import Kingfisher

// init a cache object as a global singleton
let profileCache = Cache<String, UserProfile>()
let followsCache = Cache<String, [Follows]>()

class MainViewController: UIViewController {

    @IBOutlet weak var searchResultView: UIView!

    let searchController = UISearchController(searchResultsController: nil)
    
    private let viewModel = ViewModel()
    private var error: OpenNewError?
    private var userProfile: UserProfile?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set a title value for the UI navigation
        self.title = "Github User Profile"
        
        // define configrations for the search controller object
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search User Profile"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // set delegate for the search controller object
        searchController.searchBar.delegate = self
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    
        // invoke a profile searching method from view model with a searchbar.text as a parameter
        viewModel.findUserProfileByUsername(searchBar.text!)
    }
}

extension MainViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        // update value for error from view model
        viewModel.errorStore.bind { [weak self] error in
            guard let error = error else {
                return
            }
            self?.error = error
            
            if error == OpenNewError.userNotFound {
                // init an instance of UserNotFoundView if any user profile not found
                let userNotFoundView = UIView.instanceFromNib(nibView: "UserNotFoundView") as! UserNotFoundView
                
                // add a view instance to its superview
                self?.searchResultView.addSubview(userNotFoundView)
                
                // make the subview frame in line with its superview
                userNotFoundView.frame = userNotFoundView.superview!.bounds
            }
        }
        
        // update value for userProfile from view model
        viewModel.userProfileStore.bind { [weak self] userProfile in
            guard let userProfile = userProfile else {
                return
            }
            self?.userProfile = userProfile
            
            // init an instance of UserProfileView if a user profile has been found
            let userProfileView = UIView.instanceFromNib(nibView: "UserProfileView") as! UserProfileView
            
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
            
            // add userProfileView into the view stack as a subview
            self?.searchResultView.addSubview(userProfileView)
            userProfileView.frame = userProfileView.superview!.bounds
            
            // set delegate of subview to self
            userProfileView.showFollowersViewDelegate = self
            userProfileView.showFollowingViewDelegate = self
        }
    }
}

extension MainViewController: ShowFollowersViewDelegate {
    func showFollowersView() {
        // only process further if followers count larger than 0
        guard userProfile!.followers > 0 else {
            return
        }
        
        // only process further if the followers_url valid
        guard URLHandler.verifyURL(userProfile!.followers_url) else {
            return
        }
        
        // init a instance of the main storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // init a instance of FollowerViewController
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "FollowersViewController") as! FollowersViewController
        
        // set new value for destinationVC's properties
        destinationVC.followers_url = userProfile!.followers_url
        
        // navigate to new the destination view controller
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
}

extension MainViewController: ShowFollowingViewDelegate {
    func showFollowingView() {
        // only process further if following count larger than 0
        guard userProfile!.following > 0 else {
            return
        }
        
        // only process further if the following_url valid
        guard URLHandler.verifyURL(userProfile!.following_url) else {
            return
        }
        
        // init a instance of the main storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // init a instance of FollowerViewController
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "FollowingViewController") as! FollowingViewController
        
        // set new value for destinationVC's properties
        destinationVC.following_url = userProfile!.following_url
        
        // navigate to new the destination view controller
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
}

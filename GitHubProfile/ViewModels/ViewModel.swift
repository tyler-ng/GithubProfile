//
//  ViewModel.swift
//  InterviewAssessment
//
//  Created by Ty Nguyen on 2022-01-11.
//

import Foundation

public class ViewModel {
    var errorStore: Box<OpenNewError?> = Box(nil)
    var userProfileStore: Box<UserProfile?> = Box(nil)
    var followsStore: Box<[Follows]?> = Box(nil)
    
    func findUserProfileByUsername(_ username: String) {
        // check the internet connection capacity
        if Reachability.isConnectedToNetwork() {
            NetworkingServices.findUserProfileByUsernameImplementation(username) {[weak self] (userProfile, error) in
                // back to the main thread for UI rendering
                DispatchQueue.main.async {
                    if let error = error {
                        // update value for errorStore if user profile not found
                        // the updating will force the viewModel.errorStore.bind func
                        // located in MainViewController to be executed
                        self?.errorStore.value = error.self
                        return
                    }
                    
                    guard let self = self, let userProfile = userProfile else {
                        return
                    }
                    
                    // update value for userProfileStore if user profile has been found.
                    // the updating will force the viewModel.UserProfileStore.bind func
                    // located in MainViewController to be executed
                    self.userProfileStore.value = userProfile
                }
            }
        } else {
            // loading user profile from profileCache when the internet is not available
            // implement the loading on background thread with default qos priority
            DispatchQueue.global().async {
                let userProfile = profileCache[username]
                
                // get back to the main thread for UI updating
                DispatchQueue.main.async {
                    guard let userProfile = userProfile else {
                        self.errorStore.value = OpenNewError.userNotFound
                        return
                    }
                    
                    self.userProfileStore.value = userProfile
                }
            }
        }
    }
    
    func fetchFollowsData(_ url: String) {
        // check the internet connection capacity
        if Reachability.isConnectedToNetwork() {
            NetworkingServices.fetchFollowsImplementation(url) {[weak self] (follows, error) in
                // get back to the main thread for UI rendering
                DispatchQueue.main.async {
                    if let error = error {
                        self?.errorStore.value = error.self
                        return
                    }
                    
                    guard let self = self, let follows = follows else { return }
                    
                    self.followsStore.value = follows
                }
            }
        } else {
            // loading follows data from followsCache
            DispatchQueue.global().async {
                let follows = followsCache[url]
                
                // get back to the main thread for UI updating
                DispatchQueue.main.async {
                    guard let follows = follows else {
                        self.errorStore.value = OpenNewError.userNotFound
                        return
                    }
                    
                    self.followsStore.value = follows
                }
            }
        }
    }
    
    
}

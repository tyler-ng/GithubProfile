//
//  UserProfile.swift
//  InterviewAssessment
//
//  Created by Ty Nguyen on 2022-01-11.
//

import Foundation

// User Profile Data Model
struct UserProfile {
    let avatar_url: String?
    let username: String
    let name: String?
    let description: String?
    let followers: Int
    let following: Int
    let followers_url: String
    
    static var ID: Int = 0

    var following_url: String {
        get {
            return "https://api.github.com/users/\(username)/following"
        }
    }
}

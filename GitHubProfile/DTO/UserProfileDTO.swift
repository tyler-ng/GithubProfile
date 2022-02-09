//
//  UserProfileDTO.swift
//  InterviewAssessment
//
//  Created by Ty Nguyen on 2022-01-11.
//

import Foundation

// User Profile Data Transfer Object Model
// which is used for the JSON data parsing
struct UserProfileDTO: Decodable {
    let avatar_url: String?
    let username: String
    let name: String?
    let description: String?
    let followers: Int
    let following: Int
    let followers_url: String
    
    enum CodingKeys: String, CodingKey {
        case avatar_url, name, followers, following, followers_url
        case username = "login"
        case description = "bio"
    }
}

//
//  FollowsDTO.swift
//  InterviewAssessment
//
//  Created by Ty Nguyen on 2022-01-12.
//

import Foundation

// Data Transfer Object Model for both Followers and Following JSON data
struct FollowsDTO: Decodable {
    let avatar_url: String
    let username: String
    
    enum CodingKeys: String, CodingKey {
        case avatar_url
        case username = "login"
    }
}

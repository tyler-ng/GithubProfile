//
//  NetworkingServices.swift
//  InterviewAssessment
//
//  Created by Ty Nguyen on 2022-01-11.
//

import Foundation

// defined enum for error handler
enum OpenNewError: Error {
    case invalidResponse
    case noData
    case failedRequest
    case userNotFound
    case invalidData
    case unavailableInternet
}

// The class is responsile for communicating with external resources like Github API
class NetworkingServices {
    typealias getUserProfileCompletion = (UserProfile?, OpenNewError?) -> ()
    typealias getFollowersCompletion = ([Follows]?, OpenNewError?) -> ()
    
    private static let host = "api.github.com"
    
    static func findUserProfileByUsernameImplementation(_ username: String, completion: @escaping getUserProfileCompletion) {
        let path = "/users/\(username)"
        var urlBuilder = URLComponents()
        urlBuilder.scheme = "https"
        urlBuilder.host = host
        urlBuilder.path = path
        
        guard let url = urlBuilder.url else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                print("Failed request from github.com: \(error!.localizedDescription)")
                completion(nil, .failedRequest)
                return
            }
            
            guard let data = data else {
                print("No data returned from github.com")
                completion(nil, .noData)
                return
            }

            guard let response = response as? HTTPURLResponse else {
                print("Unable to process github response")
                completion(nil, .invalidResponse)
                return
            }
            
            guard response.statusCode == 200 else {
                print("Failure response from github.com: \(response.statusCode)")
                completion(nil, .userNotFound)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                
                let userProfileDTO = try decoder.decode(UserProfileDTO.self, from: data)
                
                // create a new user profile object after the JSON parsing completed
                let userProfile: UserProfile =  UserProfile (
                    avatar_url: userProfileDTO.avatar_url,
                    username: userProfileDTO.username,
                    name: userProfileDTO.name,
                    description: userProfileDTO.description,
                    followers: userProfileDTO.followers,
                    following: userProfileDTO.following,
                    followers_url: userProfileDTO.followers_url
                )
                
                // insert user profile data into profileCache
                profileCache.insert(userProfile, forKey: userProfile.username)
                
                completion(userProfile, nil)
                
            } catch {
                print("Unable to decode Github response: \(error)")
                completion(nil, .invalidData)
            }
        }.resume()
    }
    
    static func fetchFollowsImplementation(_ url: String, completion: @escaping getFollowersCompletion) {
        
        guard let follows_url = URL(string: url) else {
            return
        }
        
        URLSession.shared.dataTask(with: follows_url) { (data, response, error) in
            guard error == nil else {
                print("Failed request from github.com: \(error!.localizedDescription)")
                completion(nil, .failedRequest)
                return
            }
            
            guard let data = data else {
                print("No data returned from github.com")
                completion(nil, .noData)
                return
            }

            guard let response = response as? HTTPURLResponse else {
                print("Unable to process github response")
                completion(nil, .invalidResponse)
                return
            }
            
            guard response.statusCode == 200 else {
                print("Failure response from github.com: \(response.statusCode)")
                completion(nil, .failedRequest)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                
                // Parsing a response data back to an array of FollowerDTO objects
                let followsDTO = try decoder.decode([FollowsDTO].self, from: data)
                
                // create a new array of the follower objects
                let follows: [Follows] = followsDTO.map {
                    Follows(avatar_url: $0.avatar_url, username: $0.username)
                }
                
                // insert follows data into followsCache
                followsCache.insert(follows, forKey: url)
                
                completion(follows, nil)
                
            } catch {
                print("Unable to decode Github response: \(error)")
                completion(nil, .invalidData)
            }
        }.resume()
    }
}

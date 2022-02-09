//
//  URLHandlers.swift
//  InterviewAssessment
//
//  Created by Ty Nguyen on 2022-01-12.
//

import Foundation
import UIKit

class URLHandler {
    static func verifyURL(_ urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
}

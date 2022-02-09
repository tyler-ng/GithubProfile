//
//  UserNotFoundView.swift
//  InterviewAssessment
//
//  Created by Ty Nguyen on 2022-01-12.
//

import UIKit

class UserNotFoundView: UIView {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textLabel.font = UIFont(name: "ArialMT", size: 20.0)
    }
}

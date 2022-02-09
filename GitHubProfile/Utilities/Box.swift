//
//  Box.swift
//  InterviewAssessment
//
//  Created by Ty Nguyen on 2022-01-11.
//

import Foundation

// this class will serve as required in the MVVM architecture
final class Box<T> {
    typealias Listener = (T) -> Void
    var listener: Listener?
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
}

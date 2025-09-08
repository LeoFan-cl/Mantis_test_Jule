//
//  SlideDialViewModel.swift
//  Mantis
//
//  Created by Yingtao Guo on 6/19/23.
//

import Foundation

public final class SlideDialViewModel {
    public var didSetRotationAngle: (Angle) -> Void = { _ in }
    
    public var rotationAngle = Angle(degrees: 0) {
        didSet {
            didSetRotationAngle(rotationAngle)
        }
    }
    
    public func reset() {
        rotationAngle = Angle(degrees: 0)
    }

    public init() {}
}

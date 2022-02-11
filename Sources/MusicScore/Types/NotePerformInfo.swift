//  NotePerformInfo.swift
//  
//
//  Created by lively77 on 2022/2/11.
//

import Foundation

/// represent a note's performance info(press and release velocity, etc.)
public struct NotePerformInfo {
    
    public init(pressVelocity: UInt8,
                releaseVelocity: UInt8) {
        self.pressVelocity = pressVelocity
        self.releaseVelocity = releaseVelocity
    }
    
    /// press velocity
    public var pressVelocity: UInt8

    /// release velocity
    public var releaseVelocity: UInt8
}

//
//  Notations.swift
//

import Foundation

/// notations


public enum SpeedChangeMode: Int {
    case fixed = 0       ///
    case accelerando = 1 ///
    case ritardando = -1 ///
}


public enum LoudnessChangeMode: Int {
    case fixed = 0         /// 
    case crescendo = 1     ///
    case decrescendo = -1  ///
}


public enum LoudnessType : Int {
    case unknown = 0
    case ppp = 1
    case pp = 2
    case p = 3
    case f = 10
    case ff = 11
    case fff = 12
}

public enum SpeedType: Int {
    case unknown = 0
}

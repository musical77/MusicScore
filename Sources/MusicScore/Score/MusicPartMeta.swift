//
//  MusicPartMeta.swift
//  

import Foundation
import MusicSymbol

/// metadata for MusicPart
public struct MusicPartMeta {
    
    /// name of this music part
    public var name: String
    
    /// instrument
    public var instrument: InstrumentType
}

extension MusicPartMeta: CustomStringConvertible {
    public var description: String {
        return "\(name), \(instrument)"
    }
}

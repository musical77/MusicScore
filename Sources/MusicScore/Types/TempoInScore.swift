//
//  TempoInScore.swift
//  

import Foundation
import MusicSymbol

/// tempo  [beginBeat, endBeat),  with a fixed tempo , and bpm changes
public struct TempoInScore {
    
    public init(tempo: Tempo,
                beginBeat: MusicTimeStamp, endBeat: MusicTimeStamp,
                innerBPM: [(MusicTimeStamp, Float64)] = []) {
        self.tempo = tempo
        self.beginBeat = beginBeat
        self.endBeat = endBeat
        self.innerBPM = innerBPM
    }
    
    /// tempo
    public var tempo: Tempo

    /// begin beat of this tempo affected
    public var beginBeat: MusicTimeStamp
    
    /// end beat of this tempo
    public var endBeat: MusicTimeStamp
    
    /// inner beat per minute changes in this tempo
    public var innerBPM: [(MusicTimeStamp, Float64)] = []
    
}

extension TempoInScore {
    
    /// time signature
    public var timeSignature: TimeSignature {
        return tempo.timeSignature
    }
    
    /// return tempo at given music timestamp
    public func getTempo(at beat: MusicTimeStamp) -> Tempo {
        var result = tempo
        for bpm in innerBPM {
            if beat >= bpm.0 {
                result.bpm = bpm.1
            }
        }
        return result
    }
}


extension Double {
    
    var as1DigitString: String {
        return String(format: "%.1f", self)
    }
    
    var as2DigitString: String {
        return String(format: "%.2f", self)
    }
    
    var as3DigitString: String {
        return String(format: "%.3f", self)
    }
    
    var as4DigitString: String {
        return String(format: "%.4f", self)
    }
}

extension TempoInScore: CustomStringConvertible {
    /// [0.000, inf) 🎼4/4 bpm:120 
    public var description: String {
        return "[\(beginBeat.as3DigitString), \(endBeat.as3DigitString)) \(tempo)" + (innerBPM.count > 1 ?
        " " + innerBPM.map { "(\($0.0.as3DigitString) bpm: \(Int($0.1)))"}.joined(separator: ",") : "")
    }
}


//
//  TempoEvent.swift
//  

import Foundation
import MusicSymbol

/// tempo  [beginBeat, endBeat),  with a fixed tempo , and bpm changes
public struct TempoEvent {
    
    public init(tempo: Tempo,
                begin: MusicTimeStampOfQuarters, end: MusicTimeStampOfQuarters,
                innerBPM: [(MusicTimeStampOfQuarters, Float64)] = []) {
        self.tempo = tempo
        self.begin = begin
        self.end = end
        self.innerBPM = innerBPM
    }
    
    /// tempo
    public var tempo: Tempo

    /// begin timestamp of this tempo affected
    public var begin: MusicTimeStampOfQuarters
    
    /// end timestamp of this tempo
    public var end: MusicTimeStampOfQuarters
    
    /// inner beat per minute changes in this tempo
    public var innerBPM: [(MusicTimeStampOfQuarters, Float64)] = []
    
}

extension TempoEvent {
    
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

extension TempoEvent: CustomStringConvertible {
    /// [0.000, inf) 🎼4/4 bpm:120 
    public var description: String {
        return "[\(begin.as3DigitString), \(end.as3DigitString)) \(tempo)" + (innerBPM.count > 1 ?
        " " + innerBPM.map { "(\($0.0.as3DigitString) bpm: \(Int($0.1)))"}.joined(separator: ",") : "")
    }
}


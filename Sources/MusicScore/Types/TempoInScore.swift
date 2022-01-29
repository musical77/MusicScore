//
//  TempoInScore.swift
//  

import Foundation
import MusicSymbol

/// tempo  [beginBeat, endBeat)
public struct TempoInScore {
    
    public init(tempo: Tempo,
                beginBeat: MusicTimeStamp, endBeat: MusicTimeStamp,
                innerBPM: [(MusicTimeStamp, Float64)] = []) {
        self.tempo = tempo
        self.beginBeat = beginBeat
        self.endBeat = endBeat
        self.innerBPM = innerBPM
    }
    
    ///
    private var tempo: Tempo

    ///
    public var beginBeat: MusicTimeStamp
    
    ///
    public var endBeat: MusicTimeStamp
    
    ///
    public var innerBPM: [(MusicTimeStamp, Float64)] = []
    
}

extension TempoInScore {
    ///
    public var timeSignature: TimeSignature {
        return tempo.timeSignature
    }
    
    public var bpm: Double {
        return tempo.bpm
    }
    
    /// Caluclates the duration of a note value in seconds.
    public func duration(of noteValue: NoteTimeValue) -> PhysicalDuration {
        return tempo.duration(of: noteValue)
    }
    
    public func duration(of note: Note) -> PhysicalDuration {
        return tempo.duration(of: note)
    }
    
    public var durationPerBeat: PhysicalDuration {
        return tempo.durationPerBeat
    }
    
    public func beats(of note: Note) -> MusicDuration {
        return tempo.beats(of: note)
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
    public var description: String {
        return "[\(beginBeat.as3DigitString), \(endBeat.as3DigitString)) \(tempo)" + (innerBPM.count > 1 ?
        " " + innerBPM.map { "\($0.0.as3DigitString) bpm: \(Int($0.1))" }.joined(separator: " ") : "")
    }
}


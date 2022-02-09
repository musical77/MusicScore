//
//  TempoChangeLog.swift
//  

import Foundation
import MusicSymbol

/// tempo  [beginBeat, endBeat),  with a fixed tempo , and bpm changes
public struct TempoChangeLog {
    
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

extension TempoChangeLog {
    
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

extension TempoChangeLog: CustomStringConvertible {
    /// [0.000, inf) 🎼4/4 bpm:120 
    public var description: String {
        return "[\(begin.as3DigitString), \(end.as3DigitString)) \(tempo)" + (innerBPM.count > 1 ?
        " " + innerBPM.map { "(\($0.0.as3DigitString) bpm: \(Int($0.1)))"}.joined(separator: ",") : "")
    }
}

/// get change logs
extension TempoChangeLog {
    static func mergeFrom(_bpms: [(MusicTimeStampOfQuarters, Float64)],
                          _signatures: [(MusicTimeStampOfQuarters, Int, NoteTimeValueType)]) -> [TempoChangeLog] {
        var bpms = _bpms
        var signatures = _signatures
        bpms.sort(by: { $0.0 < $1.0 })
        signatures.sort(by: { $0.0 < $1.0 })
        
        // merge timestamp together and sort
        var ts = bpms.map { $0.0 } + signatures.map { $0.0 }
        ts.sort()
        
        // for each [ts[i], ts[i + 1]) , calculate its bmp and time signature
        var tmpResults: [TempoChangeLog] = []
        for idx in 0..<ts.count {
            let begin = ts[idx]
            let end = idx + 1 < ts.count ? ts[idx + 1] : MusicTimeStampOfQuarters.infinity
            if begin == end {
                continue
            }
            
            // scan all bmp and time signature change timepoint, decide the current
            // bpm and current time signature
            var curBPM: Double = 0
            var curTimeSignature = TimeSignature()
            
            for bpm in bpms {
                if begin >= bpm.0 {
                    curBPM = bpm.1
                }
            }
            
            for signature in signatures {
                if begin >= signature.0 {
                    curTimeSignature.beats = signature.1
                    curTimeSignature.noteTimeValue = signature.2
                }
            }
            
            let tempo = TempoChangeLog(tempo: Tempo(timeSignature: curTimeSignature, bpm: curBPM),
                                   begin: begin, end: end)
            tmpResults.append(tempo)
        }
        
        // merge adjancent bmp changes when they have the same time signature
        var finalResults: [TempoChangeLog] = []
        var idx = 0
        while idx < tmpResults.count {
            // scan next tempos when they have the same time signature
            var tempo = tmpResults[idx]
            var idxNext = idx
            while idxNext < tmpResults.count &&
                    tmpResults[idxNext].tempo.timeSignature == tempo.tempo.timeSignature {
                idxNext = idxNext + 1
            }
            
            // merge tempos
            tempo.end = tmpResults[idxNext - 1].end
            for i in idx..<idxNext {
                tempo.innerBPM.append((tmpResults[i].begin, tmpResults[i].tempo.bpm))
            }
            finalResults.append(tempo)
            
            idx = idxNext
        }
        
        return finalResults
    }
}

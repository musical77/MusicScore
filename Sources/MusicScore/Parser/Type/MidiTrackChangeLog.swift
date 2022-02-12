//
//  TempoChangeLog.swift
//  

import Foundation
import MusicSymbol
import MidiParser

typealias MusicTimeStampOfQuarters = Float64

/// tempo  [beginBeat, endBeat),  with a fixed tempo , and bpm changes
struct MidiTrackChangeLog {
    
    public init(tempo: Tempo,
                keySignature: KeySignature,
                begin: MusicTimeStampOfQuarters,
                end: MusicTimeStampOfQuarters,
                innerBPM: [(MusicTimeStampOfQuarters, Float64)] = []) {
        self.tempo = tempo
        self.keySignature = keySignature
        self.begin = begin
        self.end = end
        self.innerBPM = innerBPM
    }
    
    /// tempo
    public var tempo: Tempo
    
    /// key signature
    public var keySignature: KeySignature
    
    /// begin timestamp of this tempo affected
    public var begin: MusicTimeStampOfQuarters
    
    /// end timestamp of this tempo
    public var end: MusicTimeStampOfQuarters
    
    /// inner beat per minute changes in this tempo
    public var innerBPM: [(MusicTimeStampOfQuarters, Float64)] = []
    
}

extension MidiTrackChangeLog {
    
    /// time signature
    public var timeSignature: TimeSignature {
        return tempo.timeSignature
    }
    
    /// return tempo at given music timestamp
    public func getTempo(at ts: MusicTimeStampOfQuarters) -> Tempo {
        var result = tempo
        for bpm in innerBPM {
            if ts >= bpm.0 {
                result.bpm = bpm.1
            }
        }
        return result
    }
}

extension MidiTrackChangeLog: CustomStringConvertible {
    /// [0.000, inf) 🎼4/4 bpm:120
    public var description: String {
        return "[\(begin.as3DigitString), \(end.as3DigitString)) \(tempo)" + (innerBPM.count > 1 ?
                                                                              " " + innerBPM.map { "(\($0.0.as3DigitString) bpm: \(Int($0.1)))"}.joined(separator: ",") : "")
    }
}

/// get change logs
extension MidiTrackChangeLog {
    static func mergeFrom(_bpms: [(MusicTimeStampOfQuarters, Float64)],
                          _signatures: [(MusicTimeStampOfQuarters, Int, NoteTimeValueType)],
                          _keySignatures: [(MusicTimeStampOfQuarters, KeySignature)]) -> [MidiTrackChangeLog] {
        var bpms = _bpms
        var signatures = _signatures
        var keySigns = _keySignatures
        
        bpms.sort(by: { $0.0 < $1.0 })
        signatures.sort(by: { $0.0 < $1.0 })
        keySigns.sort(by: { $0.0 < $1.0 })
        
        // merge timestamp together and sort
        var ts = bpms.map { $0.0 } + signatures.map { $0.0 } + keySigns.map { $0.0 }
        ts.sort()
        
        // for each [ts[i], ts[i + 1]) , calculate its bmp and time signature
        var tmpResults: [MidiTrackChangeLog] = []
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
            var curKeySignature = KeySignature.major(.C)
            
            // get bmp in current time window
            for bpm in bpms {
                if begin >= bpm.0 {
                    curBPM = bpm.1
                }
            }
            
            // get tempo signature in current time window
            for signature in signatures {
                if begin >= signature.0 {
                    curTimeSignature.beats = signature.1
                    curTimeSignature.noteTimeValue = signature.2
                }
            }
            
            // get key signature in current time window
            for keySign in keySigns {
                if begin >= keySign.0 {
                    curKeySignature = keySign.1
                }
            }
            
            let tempo = MidiTrackChangeLog(tempo: Tempo(timeSignature: curTimeSignature, bpm: curBPM),
                                           keySignature: curKeySignature,
                                           begin: begin,
                                           end: end)
            tmpResults.append(tempo)
        }
        
        // merge adjancent bmp changes when they have the same time signature
        var finalResults: [MidiTrackChangeLog] = []
        var idx = 0
        while idx < tmpResults.count {
            // scan next tempos when they have the same time signature and key signature
            var cur = tmpResults[idx]
            var idxNext = idx
            while idxNext < tmpResults.count &&
                    tmpResults[idxNext].tempo.timeSignature == cur.tempo.timeSignature &&
                    tmpResults[idxNext].keySignature == cur.keySignature {
                idxNext = idxNext + 1
            }
            
            // merge tempos
            cur.end = tmpResults[idxNext - 1].end
            for i in idx..<idxNext {
                cur.innerBPM.append((tmpResults[i].begin, tmpResults[i].tempo.bpm))
            }
            finalResults.append(cur)
            
            idx = idxNext
        }
        
        return finalResults
    }
    
}

/// double extension
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

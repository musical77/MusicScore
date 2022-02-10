
import os
import Foundation
import MusicSymbol

import MidiParser

/// Tempo related info extractor
class TempoExtractor {
    
    /// get TimeSignature changes
    func getTimeSignatures(midi: MidiData) -> [(MusicTimeStampOfQuarters, Int, NoteTimeValueType)] {
        var results: [(MusicTimeStampOfQuarters, Int, NoteTimeValueType)] = []
        
        for ts in midi.tempoTrack.timeSignatures {
            // numerator / 2^denominator
            results.append((ts.timeStamp, Int(ts.numerator), NoteTimeValueType(denominator: Int(ts.denominator))!))
        }
        
        return results
    }
    
    /// get bpm changes
    func getBPMs(midi: MidiData) -> [(MusicTimeStampOfQuarters, Float64)] {
        var results: [(MusicTimeStampOfQuarters, Float64)] = []
        
        for event in midi.tempoTrack.extendedTempos {
            results.append((event.timeStamp, event.bpm))
        }
        
        return results
    }
    
    private var logger = Logger(subsystem: "MusicScore", category: "TempoParser")
}


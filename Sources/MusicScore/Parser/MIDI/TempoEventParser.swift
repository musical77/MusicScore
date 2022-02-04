
import os
import Foundation
import MusicSymbol
import AudioToolbox

/// TempoEventParser
class TempoEventParser {
    
    /// extract tempo infos from MIDISequence
    func getTempoInScores(_ midi: MIDISequence) -> [TempoEvent] {
        let tempoEvents = midi.getTempoTrackEvents()
        
        // get bmp changes and signuature changes, sort in asc order
        var bpms = getBPMs(events: tempoEvents)
        var signatures = getSignature(events: tempoEvents)
        bpms.sort(by: { $0.0 < $1.0 })
        signatures.sort(by: { $0.0 < $1.0 })
        
        // merge timestamp together and sort
        var ts = bpms.map { $0.0 } + signatures.map { $0.0 }
        ts.sort()
        
        // for each [ts[i], ts[i + 1]) , calculate its bmp and time signature
        var tmpResults: [TempoEvent] = []
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
            
            // by default, midi timestamp is counted based on number of quarters
//            let timeSignatureFactor = NoteTimeValueType.quarter / curTimeSignature.noteTimeValue
            
            let tempo = TempoEvent(tempo: Tempo(timeSignature: curTimeSignature, bpm: curBPM),
                                     begin: begin, end: end)
            tmpResults.append(tempo)
        }
        
        // merge adjancent bmp changes when they have the same time signature
        var finalResults: [TempoEvent] = []
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
    
    /// privates
    
    /// get all beat per minute changes
    /// - Returns [ (change time, beat per minute) ]
    private func getBPMs(events: [TimedMIDIEvent]) -> [(MusicTimeStampOfQuarters, Float64)] {
        var results: [(MusicTimeStampOfQuarters, Float64)] = []
        
        for event in events {
            if event.eventType == kMusicEventType_ExtendedTempo {
                let bpm = event.tempoEvent?.bpm ?? 60.0
                logger.info("found bmp at: \(event.eventTimeStamp), bmp: \(event.tempoEvent?.bpm ?? 60.0)")
                results.append((event.eventTimeStamp, bpm))
            }
        }
        
        return results
    }
    
    /// get all signatures such as (4/4) (3/8)
    /// - Returns [ (change time of this signature, beat per measure, beat note type) ]
    private func getSignature(events: [TimedMIDIEvent]) -> [(MusicTimeStampOfQuarters, Int, NoteTimeValueType)] {
        var results: [(MusicTimeStampOfQuarters, Int, NoteTimeValueType)] = []
        
        for event in events {
            /// FF 58 04 nn dd cc bb Time Signature
            /// The time signature is expressed as four numbers. nn and dd represent the numerator and denominator of the time signature as it would be notated. The denominator is a negative power of two: 2 represents a quarter-note, 3 represents an eighth-note, etc. The cc parameter expresses the number of MIDI clocks in a metronome click. The bb parameter expresses the number of notated 32nd-notes in a MIDI quarter-note (24 MIDI clocks). This was added because there are already multiple programs which allow a user to specify that what MIDI thinks of as a quarter-note (24 clocks) is to be notated as, or related to in terms of, something else.
            if let meta = event.midiMetaEventTempo {
                if meta.metaEventType == 0x58 {
                    let beatsPerMeasure = Int(meta.nn)
                    var tempoNoteType: NoteTimeValueType = .quarter
                    switch meta.dd {
                    case 1:
                        tempoNoteType = .half
                    case 2:
                        tempoNoteType = .quarter
                    case 3:
                        tempoNoteType = .eighth
                    case 4:
                        tempoNoteType = .sixteenth
                    default:
                        logger.error("tempo note type is not supported yet, dd:\(meta.dd)")
                    }
                    logger.info("found tempo info at: \(event.eventTimeStamp), beatsPerMeasure: \(beatsPerMeasure), note type: \(tempoNoteType)")
                    
                    results.append((event.eventTimeStamp, beatsPerMeasure, tempoNoteType))
                }
            }
        }
        
        return results
    }
    
    private var logger = Logger(subsystem: "MusicScore", category: "TempoParser")
}




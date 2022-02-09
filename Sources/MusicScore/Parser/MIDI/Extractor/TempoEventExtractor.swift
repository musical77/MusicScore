
import os
import Foundation
import MusicSymbol
import AudioToolbox

import MidiParser

/// TempoEventParser
class TempoEventExtractor {
    
    private var logger = Logger(subsystem: "MusicScore", category: "TempoParser")
}

extension TempoEventExtractor {
    /// get all beat per minute changes
    /// - Returns [ (change time, beat per minute) ]
    func getBPMs(events: [TimedMIDIEvent]) -> [(MusicTimeStampOfQuarters, Float64)] {
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
    
    /// get all time signatures such as (4/4) (3/8)
    /// - Returns [ (change time of this signature, beat per measure, beat note type) ]
    func getTimeSignatures(events: [TimedMIDIEvent]) -> [(MusicTimeStampOfQuarters, Int, NoteTimeValueType)] {
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
    
    func getTimeSignatures(midi: MidiData) -> [(MusicTimeStampOfQuarters, Int, NoteTimeValueType)] {
        var results: [(MusicTimeStampOfQuarters, Int, NoteTimeValueType)] = []
        
        for ts in midi.tempoTrack.timeSignatures {
            // numerator / 2^denominator
            results.append((ts.timeStamp, Int(ts.numerator), NoteTimeValueType(denominator: Int(ts.denominator))!))
        }
        
        return results
    }
    
    func getBPMs(midi: MidiData) -> [(MusicTimeStampOfQuarters, Float64)] {
        var results: [(MusicTimeStampOfQuarters, Float64)] = []
        
        for event in midi.tempoTrack.extendedTempos {
            results.append((event.timeStamp, event.bpm))
        }
        
        return results
    }
}


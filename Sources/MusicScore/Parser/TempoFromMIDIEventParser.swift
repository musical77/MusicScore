
import os
import Foundation
import MusicSymbol
import AudioToolbox

//MARK: tempo parser
class TempoFromMIDIEventParser {
    
    func getTempo(_ midi: MIDISequence) -> [TempoInScore] {
        let tempoEvents = midi.getTempoTrackEvents()
        
        //
        var bpms = getBPMs(events: tempoEvents)
        var signatures = getSignature(events: tempoEvents)
        bpms.sort(by: { $0.0 < $1.0 })
        signatures.sort(by: { $0.0 < $1.0 })
        var ts = bpms.map { $0.0 } + signatures.map { $0.0 }
        ts.sort()
        
        //
        var tmpResults: [TempoInScore] = []
        
        // 
        for idx in 0..<ts.count {
            let beginBeat = ts[idx]
            let endBeat = idx + 1 < ts.count ? ts[idx + 1] : MusicTimeStamp.infinity
            if beginBeat == endBeat {
                continue
            }
            
            var cur_bpm: Double = 0
            var timeSignature = TimeSignature()
            
            for bpm in bpms {
                if beginBeat >= bpm.0 {
                    cur_bpm = bpm.1
                }
            }
            
            for signature in signatures {
                if beginBeat >= signature.0 {
                    timeSignature.beats = signature.1
                    timeSignature.noteTimeValue = signature.2
                }
            }
            
            let tempo = TempoInScore(tempo: Tempo(timeSignature: timeSignature, bpm: cur_bpm),
                                     beginBeat: beginBeat, endBeat: endBeat)
            tmpResults.append(tempo)
        }
        
        //
        var finalResults: [TempoInScore] = []
        var idx = 0
        while idx < tmpResults.count {
            //
            var tempo = tmpResults[idx]
            var idxNext = idx
            while idxNext < tmpResults.count &&
                    tmpResults[idxNext].timeSignature == tempo.timeSignature {
                idxNext = idxNext + 1
            }
            
            //
            tempo.endBeat = tmpResults[idxNext - 1].endBeat
            for i in idx..<idxNext {
                tempo.innerBPM.append((tmpResults[i].beginBeat, tmpResults[i].bpm))
            }
            finalResults.append(tempo)
            
            idx = idxNext
        }
        
        return finalResults
    }
    
    ///
    private func getBPMs(events: [TimedMIDIEvent]) -> [(MusicTimeStamp, Float64)] {
        var results: [(MusicTimeStamp, Float64)] = []
        
        for event in events {
            if event.eventType == kMusicEventType_ExtendedTempo {
                let bpm = event.tempoEvent?.bpm ?? 60.0
                logger.info("found bmp at: \(event.eventTimeStamp), bmp: \(event.tempoEvent?.bpm ?? 60.0)")
                results.append((event.eventTimeStamp, bpm))
            }
        }
        
        return results
    }
    
    ///
    private func getSignature(events: [TimedMIDIEvent]) -> [(MusicTimeStamp, Int, NoteTimeValueType)] {
        var results: [(MusicTimeStamp, Int, NoteTimeValueType)] = []
        
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




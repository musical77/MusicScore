//  NoteInfoExtractor.swift
//
//  Created by lively77 on 2022/2/10.

import Foundation
import MidiParser
import MusicSymbol

class NoteExtractor {
    
    /// extract note info from midi track
    func getNotes(tempos: [TempoChangeLog], noteTrack: MidiNoteTrack) -> [NoteInScore] {
        
        var notes: [NoteInScore] = []
        for idx in noteTrack.startIndex..<noteTrack.endIndex {
            let midiNote = noteTrack[idx]
            
            // get tempo of this note
            let tempo = getTempo(ts: midiNote.regularTempoTimeStamp, with: tempos)!
            
            // time signature factor, TODO: now we assume tempo.timeSignature is fixed
            let factor = NoteTimeValue(type: .quarter) / tempo.timeSignature.noteTimeValue
            
            // midiNote.duration is beats this note lasts, TODO implement preferSharps
            let timeValue = tempo.timeSignature.noteTimeValue * (Double(midiNote.regularDuration) * factor)
            let note = Note(pitch: Pitch(midiNote: Int(midiNote.note), preferSharps: true),
                            timeValue: timeValue!)
            
            let performInfo = NotePerformInfo(pressVelocity: midiNote.velocity,
                                              releaseVelocity: midiNote.releaseVelocity)
            
            let noteInScore = NoteInScore(note: note,
                                          tempo: tempo,
                                          beginBeat: midiNote.regularTempoTimeStamp * factor,
                                          performInfo: performInfo)
            
            notes.append(noteInScore)
            
        }
        
        return notes
    }
    
    /// get tempo at given timestamp
    /// - Parameter ts music time stamp of quarters
    func getTempo(ts: MusicTimeStampOfQuarters, with tempos: [TempoChangeLog]) -> Tempo? {
        for tempo in tempos {
            if ts >= tempo.begin && ts < tempo.end {
                return tempo.getTempo(at: ts)
            }
        }
        return nil
    }
}

//  NoteInfoExtractor.swift
//
//  Created by lively77 on 2022/2/10.

import Foundation
import MidiParser
import MusicSymbol

class NoteExtractor {
    
    /// extract note info from midi track
    func getNotes(logs: [MidiTrackChangeLog], noteTrack: MidiNoteTrack) -> [NoteInScore] {
        
        var notes: [NoteInScore] = []
        for idx in noteTrack.startIndex..<noteTrack.endIndex {
            let midiNote = noteTrack[idx]
            
            // get tempo of this note
            var tempo = getTempo(ts: midiNote.regularTempoTimeStamp, among: logs)!
            
            // get key signature of this note
            let keySign = getKeySign(ts: midiNote.regularTempoTimeStamp, among: logs)!
            
            // time signature factor, TODO: now we assume tempo.timeSignature's noteTimeValue is fixed
            let factor = NoteTimeValue(type: .quarter) / tempo.timeSignature.noteTimeValue
            
            // adjust tempo bpm because in midi bpm is measured as quarter notes
            tempo.bpm = tempo.bpm * factor
            
            // midiNote.duration is beats this note lasts
            let timeValue = tempo.timeSignature.noteTimeValue * (Double(midiNote.regularDuration) * factor)
            let note = Note(pitch: Pitch(midiNote: Int(midiNote.note), preferSharps: !keySign.isFlat),
                            timeValue: timeValue!)
            
            // get perform guidance
            let performInfo = NotePerformInfo(pressVelocity: midiNote.velocity,
                                              releaseVelocity: midiNote.releaseVelocity)
            
            // wow, finally we got the note 
            let noteInScore = NoteInScore(note: note,
                                          tempo: tempo,
                                          keySignature: keySign,
                                          beginBeat: midiNote.regularTempoTimeStamp * factor,
                                          performInfo: performInfo)
            
            notes.append(noteInScore)
            
        }
        
        return notes
    }
    
    /// get tempo at given timestamp
    /// - Parameter ts music time stamp of quarters
    func getTempo(ts: MusicTimeStampOfQuarters, among logs: [MidiTrackChangeLog]) -> Tempo? {
        for tempo in logs {
            if ts >= tempo.begin && ts < tempo.end {
                return tempo.getTempo(at: ts)
            }
        }
        return nil
    }
    
    /// get key signature at given timestamp
    func getKeySign(ts: MusicTimeStampOfQuarters, among logs: [MidiTrackChangeLog]) -> KeySignature? {
        for key in logs {
            if ts >= key.begin && ts < key.end {
                return key.keySignature
            }
        }
        return nil
    }
}

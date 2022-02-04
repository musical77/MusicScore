//  MusicPart.swift
//
//  Copyright © 2022 live77. All rights reserved.


import Foundation
import os

import MusicSymbol

public typealias MusicPartID = Int

/// Used to represent a voice part, an independent instrumental unit
public struct MusicPart {
    
    ///
    var id: MusicPartID = 0
    
    /// meta
    public var meta: MusicPartMeta = MusicPartMeta(name: "", instrument: .unknown)
    
    /// notes , sorted in time asc order
    public var notes: [NoteInScore] = []
    
    /// measures, sorted in order
    public var measures: [Measure] = []
    
    /// duration of this music part
    public var musicDuration: MusicDuration {
        return notes.map { $0.beginBeat + $0.beats }.max() ?? 0
    }
    
    /// private
    private var logger = Logger(subsystem: "MusicScore", category: "MusicPart")
    private var metaParser = MusicPartMetaFromMIDIEventParser()
}

// MARK: conv init
extension MusicPart {
    
    /// - parameter id
    /// - parameter name
    /// - parameter tempos
    /// - parameter midiEvents
    init(id: MusicPartID,
         named name: String,
         with tempos: [TempoEvent],
         midiEvents: [TimedMIDIEvent]) {
        self.init()
        
        self.id = id
        self.meta = MusicPartMeta(name: name,
                                  instrument: metaParser.getInstrument(midiEvents: midiEvents))
                
        var notes: [NoteInScore] = []
        for event in midiEvents {
            if let midiNote = event.midiNoteMessage {
                // get tempo of this note
                let tempo = MusicPart.getTempo(ts: event.eventTimeStamp, with: tempos)!
                
                // time signature factor, TODO , now we assume tempo.timeSignature is fixed
                let factor = NoteTimeValue(type: .quarter) / tempo.timeSignature.noteTimeValue
                
                // midiNote.duration is beats this note lasts
                let timeValue = tempo.timeSignature.noteTimeValue * (Double(midiNote.duration) * factor)
                let note = Note(pitch: Pitch(integerLiteral: Int(midiNote.note)),
                                timeValue: timeValue!)
                
                let noteInScore = NoteInScore(note: note,
                                              tempo: tempo,
                                              pressVelocity: midiNote.velocity,
                                              releaseVelocity: midiNote.releaseVelocity,
                                              beginBeat: event.eventTimeStamp * factor)
                
                notes.append(noteInScore)
            }
        }
        
        self.notes = notes
        self.measures = MusicPart.getMeasures(notes: notes)
    }
}


extension MusicPart {
    
    /// get tempo
    private static func getTempo(ts: MusicTimeStampOfQuarters, with tempos: [TempoEvent]) -> Tempo? {
        for tempo in tempos {
            if ts >= tempo.begin && ts < tempo.end {
                return tempo.getTempo(at: ts)
            }
        }
        return nil
    }
    
    /// get measures
    private static func getMeasures(notes: [NoteInScore]) -> [Measure] {
        var measures : [Measure] = []
        var idx = 0
        
        var beginBeat = 0.0
        var endBeat = 0.0
        while idx < notes.count {
            let firstNote = notes[idx]
            let tempo = firstNote.tempo
            beginBeat = endBeat
            endBeat = beginBeat + Double(tempo.timeSignature.beats)
            
            var nextIdx = idx
            var notesInMeasure: [NoteInScore] = []
            while nextIdx < notes.count && notes[nextIdx].beginBeat < endBeat {
                notesInMeasure.append(notes[nextIdx])
                nextIdx = nextIdx + 1
            }
            
            measures.append(Measure(index: measures.count,
                                    notes: notesInMeasure,
                                    beginBeat: beginBeat,
                                    endBeat: endBeat))
            
            idx = nextIdx
        }
        
        return measures
    }
}

// MARK: string ext
extension MusicPart: CustomStringConvertible {
    public var description: String {
        return "MusicPart: \(meta)\n" + measures.map { "----------------" + "\n" + $0.description }.joined(separator: "\n")
    }
}

// MARK: hash ext
extension MusicPart: Hashable {
    public static func == (lhs: MusicPart, rhs: MusicPart) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

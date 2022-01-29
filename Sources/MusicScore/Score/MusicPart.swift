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
    
    /// tempos
    public var tempos: [TempoInScore] = []
    
    /// measures, sorted in order
    public var measures: [Measure] = []
    
    /// duration of this music part
    public var musicDuration: MusicDuration {
        return notes.map { $0.beginBeat + $0.beats }.max() ?? 0
    }
    
    // MARK: private
    private var logger = Logger(subsystem: "Lively77MusicScore", category: "MusicPart")
    private var metaParser = MusicPartMetaFromMIDIEventParser()
}

extension MusicPart {
    
    /// return given measure
    public subscript(idx: Int) -> Measure {
        return measures[idx]
    }
    
    /// return notes in [beginBeat, endBeat)
    public subscript(beginBeat: MusicTimeStamp, endBeat: MusicTimeStamp) -> [NoteInScore] {
        return notes.filter({ $0.beginBeat >= beginBeat && $0.beginBeat < endBeat })
    }
    
    /// cut this MusicPart
    public mutating func cut(beginBeat: MusicTimeStamp, endBeat: MusicTimeStamp) {
        self.notes = notes.filter({ $0.beginBeat >= beginBeat && $0.beginBeat < endBeat })
        self.tempos = tempos.filter({ $0.beginBeat >= beginBeat && $0.beginBeat < endBeat })
        self.measures = MusicPart.getMeasures(notes: self.notes, with: self.tempos, maxBeat: endBeat)
    }
}

// MARK: conv init
extension MusicPart {
    
    /// - parameter id
    /// - parameter name
    /// - parameter tempos
    /// - parameter midiEvents
    init(id: MusicPartID,
         named name: String,
         with tempos: [TempoInScore],
         midiEvents: [TimedMIDIEvent]) {
        self.init()
        
        self.id = id
        self.meta = MusicPartMeta(name: name,
                                  instrument: metaParser.getInstrument(midiEvents: midiEvents))
        self.tempos = tempos
                
        var notes: [NoteInScore] = []
        for event in midiEvents {
            if let midiNote = event.midiNoteMessage {
                let tempo = MusicPart.getTempo(ts: event.eventTimeStamp, with: tempos)!
                
                //
                let timeValue = tempo.timeSignature.noteTimeValue * Double(midiNote.duration)
                let note = Note(pitch: Pitch(integerLiteral: Int(midiNote.note)),
                                timeValue: timeValue!)
                
                let noteInScore = NoteInScore(note: note,
                                              tempo: tempo,
                                              pressVelocity: midiNote.velocity,
                                              releaseVelocity: midiNote.releaseVelocity,
                                              beginBeat: event.eventTimeStamp)
                
                notes.append(noteInScore)
            }
        }
        
        self.notes = notes
        let maxBeat = notes.map { $0.beginBeat + $0.beats }.max() ?? 0
        self.measures = MusicPart.getMeasures(notes: notes, with: tempos, maxBeat: maxBeat)
    }
}


extension MusicPart {
    
    /// get tempo
    private static func getTempo(ts: MusicTimeStamp, with tempos: [TempoInScore]) -> TempoInScore? {
        for tempo in tempos {
            if ts >= tempo.beginBeat && ts < tempo.endBeat {
                return tempo
            }
        }
        return nil
    }
    
    /// get measures
    private static func getMeasures(notes: [NoteInScore],
                                    with tempos: [TempoInScore],
                                    maxBeat: MusicTimeStamp) -> [Measure] {
        var measures : [Measure] = []
        var idx = 0
        for tempoIdx in 0..<tempos.count {
            let tempo = tempos[tempoIdx]
            let beginBeat = tempo.beginBeat
            let endBeat = min(maxBeat, tempo.endBeat)
            
            let beatPerMeasure = Double(tempo.timeSignature.beats)
            var newBeatBegin = beginBeat
            while newBeatBegin < endBeat - 1e-6 {
                measures.append(Measure(index: idx, notes: [],
                                        beginBeat: newBeatBegin,
                                        endBeat: min(newBeatBegin + beatPerMeasure, endBeat),
                                        tempo: tempo))
                idx = idx + 1
                newBeatBegin = newBeatBegin + beatPerMeasure
            }
        }
        
        // for each measure, find event 
        for measureIdx in 0..<measures.count {
            for event in notes {
                let position = event.beginBeat
                if position >= measures[measureIdx].beginBeat &&
                    position < measures[measureIdx].endBeat {
                    measures[measureIdx].notes.append(event)
                }
            }
        }
        
        return measures
    }
}

// MARK: string ext
extension MusicPart: CustomStringConvertible {
    public var description: String {
        return "meta: \(meta)\n" + measures.map { "----------------" + "\n" + $0.description }.reduce("", +)
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

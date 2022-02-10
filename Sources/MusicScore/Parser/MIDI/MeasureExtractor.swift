//  MeasureExtractor.swift
//  
//  Created by lively77 on 2022/2/10.

import Foundation
import MusicSymbol
import MidiParser

class MeasureExtractor {
    
    /// get measure ranges [(beginBeat, endBeat)]
    func getMeasureRanges(notes: [NoteInScore]) -> [(MusicTimeStamp, MusicTimeStamp)] {
        var measureRanges : [(MusicTimeStamp, MusicTimeStamp)] = []
        var idx = 0
        
        var beginBeat = 0.0
        var endBeat = 0.0
        while idx < notes.count {
            let firstNote = notes[idx]
            let tempo = firstNote.tempo
            beginBeat = endBeat
            endBeat = beginBeat + Double(tempo.timeSignature.beats)
            
            var nextIdx = idx
            while nextIdx < notes.count && notes[nextIdx].beginBeat < endBeat {
                nextIdx = nextIdx + 1
            }
            
            measureRanges.append((beginBeat, endBeat))
            idx = nextIdx
        }
        
        return measureRanges
    }
    
    /// get measures based on all notes and ranges
    func getMeasures(notes: [NoteInScore], ranges: [(MusicTimeStamp, MusicTimeStamp)]) -> [Measure] {
        var measures: [Measure] = []
        
        for idx in 0..<ranges.count {
            let range = ranges[idx]
            let notesInMeasure = notes.filter { $0.beginBeat >= range.0 && $0.beginBeat < range.1 }
            let measure = Measure(index: idx, notes: notesInMeasure, beginBeat: range.0, endBeat: range.1)
            measures.append(measure)
        }
        
        return measures
    }
}

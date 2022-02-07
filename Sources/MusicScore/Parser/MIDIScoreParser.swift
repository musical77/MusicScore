//  MIDIScoreParser.swift
//
//  Created by lively77 on 2022/2/4.

import os
import Foundation
import MusicSymbol

class MIDIScoreParser {
    
    /// load a music score from midi file url
    public func getMusicScore(url: URL) -> MusicScore? {
        guard let midi = MIDISequence(url: url) else {
            logger.error("failed to load midi sequence from \(url.description)")
            return nil
        }
        
        var result = MusicScore()
        result.name = url.lastPathComponent
        logger.info("\(url.description) music sound tracks without meta: \(midi.getNumberOfSoundTracks())")

        // extract music parts
        result.musicParts = getMusicParts(midi: midi)
        return result
    }
    
    private let tempoParser = TempoEventExtractor()
    private let metaParser = InstrumentTypeExtractor()
    
    private let logger = Logger(subsystem: "MusicScore", category: "MIDIScoreParser")
    
}

extension MIDIScoreParser {
    
    private func getMusicParts(midi: MIDISequence) -> [MusicPart] {
        // extract tempos
        let tempoEvents = tempoParser.getTempoInScores(midi)
        for tempo in tempoEvents {
            logger.info("tempo: \(tempo)")
        }
        
        // extract all notes in all music parts
        var notesInTracks: [[NoteInScore]] = []
        var allNotes: [NoteInScore] = []
        for idx in 0..<(midi.getNumberOfSoundTracks()) {
            let events = midi.getTrackEvents(trackIndex: idx)
            let notes = getNotes(tempos: tempoEvents, midiEvents: events)
            notesInTracks.append(notes)
            allNotes.append(contentsOf: notes)
        }
        
        // get measure ranges
        let ranges = getMeasureRanges(notes: allNotes)
        
        // get final music parts
        var result: [MusicPart] = []
        for idx in 0..<(midi.getNumberOfSoundTracks()) {
            let notes = notesInTracks[idx]
            
            // skip empty track
            if notes.isEmpty {
                logger.warning("track \(idx), has no note events, skip it")
                continue
            }
            
            let events = midi.getTrackEvents(trackIndex: idx)
            let instrument = metaParser.getInstrument(midiEvents: events)
            let name = instrument.description + "_\(idx)"
            let measures = getMeasures(notes: notes, ranges: ranges)
            let part = MusicPart(id: idx, name: name, instrument: instrument, notes: notes, measures: measures)
                        
            result.append(part)
            logger.info("track \(idx), has notes: \(part.notes.count), instr: \(part.meta.instrument.description)")
        }
        
        return result
    }
    
    /// get notes in a track
    private func getNotes(tempos: [TempoEvent],
                  midiEvents: [TimedMIDIEvent]) -> [NoteInScore] {
        
        var notes: [NoteInScore] = []
        for event in midiEvents {
            if let midiNote = event.midiNoteMessage {
                // get tempo of this note
                let tempo = getTempo(ts: event.eventTimeStamp, with: tempos)!
                
                // time signature factor, TODO: now we assume tempo.timeSignature is fixed
                let factor = NoteTimeValue(type: .quarter) / tempo.timeSignature.noteTimeValue
                
                // midiNote.duration is beats this note lasts, TODO implement preferSharps
                let timeValue = tempo.timeSignature.noteTimeValue * (Double(midiNote.duration) * factor)
                let note = Note(pitch: Pitch(midiNote: Int(midiNote.note), preferSharps: true),
                                timeValue: timeValue!)
                
                let noteInScore = NoteInScore(note: note,
                                              tempo: tempo,
                                              pressVelocity: midiNote.velocity,
                                              releaseVelocity: midiNote.releaseVelocity,
                                              beginBeat: event.eventTimeStamp * factor)
                
                notes.append(noteInScore)
            }
        }
        
        return notes
    }
    
    /// get tempo
    private func getTempo(ts: MusicTimeStampOfQuarters, with tempos: [TempoEvent]) -> Tempo? {
        for tempo in tempos {
            if ts >= tempo.begin && ts < tempo.end {
                return tempo.getTempo(at: ts)
            }
        }
        return nil
    }
    
    /// get measure ranges [(beginBeat, endBeat)]
    private func getMeasureRanges(notes: [NoteInScore]) -> [(MusicTimeStamp, MusicTimeStamp)] {
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
    
    private func getMeasures(notes: [NoteInScore], ranges: [(MusicTimeStamp, MusicTimeStamp)]) -> [Measure] {
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

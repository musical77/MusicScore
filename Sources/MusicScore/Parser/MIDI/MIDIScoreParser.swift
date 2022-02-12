//  MIDIScoreParser.swift
//
//  Created by lively77 on 2022/2/4.

import os
import Foundation
import MusicSymbol
import MidiParser

public class MIDIScoreParser {
    
    public init() {}
    
    public func loadMusicScore(url: URL) -> MusicScore? {
        guard let data = try? Data(contentsOf: url) else {
            logger.error("failed to load data from url: \(url.description)")
            return nil
        }
        
        let midi = MidiData()
        midi.load(data: data)
        
        var result = MusicScore()
        result.name = url.lastPathComponent
        result.musicParts = getMusicParts(midi: midi)
        
        return result
    }
    
    private let tempoExtractor = TempoExtractor()
    private let noteExtractor = NoteExtractor()
    private let measureExtractor = MeasureExtractor()
    private let keySignExtractor = KeySignatureExtractor()
    
    private let logger = Logger(subsystem: "MusicScore", category: "MIDIScoreParser")
}

extension MIDIScoreParser {
    
    private func getMusicParts(midi: MidiData) -> [MusicPart] {
        // 1.0 extract tempo events
        let bpms = tempoExtractor.getBPMs(midi: midi)
        let signatures = tempoExtractor.getTimeSignatures(midi: midi)
        
        // extract all notes in all music parts
        var notesInTracks: [[NoteInScore]] = []
        var allNotes: [NoteInScore] = []
        for idx in 0..<midi.noteTracks.count {
            let noteTrack = midi.noteTracks[idx]
            let keySigns = keySignExtractor.getKeySignatures(noteTrack: midi.noteTracks[idx])
            let midiChangeLogs = MidiTrackChangeLog.mergeFrom(
                _bpms: bpms, _signatures: signatures, _keySignatures: keySigns)

            let notes = noteExtractor.getNotes(logs: midiChangeLogs, noteTrack: noteTrack)
            notesInTracks.append(notes)
            allNotes.append(contentsOf: notes)
        }
        
        // get measure ranges
        let ranges = measureExtractor.getMeasureRanges(notes: allNotes)
        
        // get final music parts
        var result: [MusicPart] = []
        var instrument = InstrumentType.unknown
        for idx in 0..<notesInTracks.count {
            let notes = notesInTracks[idx]
            
            // skip empty track
            if notes.isEmpty {
                logger.warning("track \(idx), has no note events, skip it")
                continue
            }
            
            // get instrument type, if don't find instrument 
            if let midiPatch = midi.noteTracks[idx].patch {
                instrument = InstrumentType(rawValue: Int(midiPatch.patch.rawValue))!
            }
            let name = String(reflecting: instrument) + "_\(idx)"
            let measures = measureExtractor.getMeasures(notes: notes, ranges: ranges)
            let part = MusicPart(name: name, instrument: instrument, notes: notes, measures: measures)
            
            result.append(part)
            logger.info("track \(idx), has notes: \(part.notes.count), instr: \(name),\(instrument.rawValue)")
        }
        
        return result
    }
    
}

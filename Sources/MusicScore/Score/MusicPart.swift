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
        name: String,
        instrument: InstrumentType,
        notes: [NoteInScore],
        measures: [Measure]) {
        
        self.id = id
        self.meta = MusicPartMeta(name: name, instrument: instrument)
        self.notes = notes
        self.measures = measures
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

//
//  NoteInScore.swift
//  

import Foundation
import MusicSymbol
import MidiParser

/// represent a note in score , has its position info(beginBeat) , and its performance info(press and release velocity)
public struct NoteInScore {
    
    public init(note: Note,
                tempo: Tempo,
                keySignature: KeySignature,
                beginBeat: MusicTimeStamp,
                performInfo: NotePerformInfo) {
        self.note = note
        self.tempo = tempo
        self.keySignature = keySignature
        self.beginBeat = beginBeat
        self.performInfo = performInfo
    }
    
    /// note
    public var note: Note
    
    /// tempo of this note being played
    public var tempo: Tempo
    
    /// key signature of this note
    public var keySignature: KeySignature

    /// position in time, measured in beats, begin
    public var beginBeat: MusicTimeStamp
    
    /// how to play this note 
    public var performInfo: NotePerformInfo? = nil
}

extension NoteInScore {
    
    /// the duration for the note,
    public var phyDuration: PhysicalDuration {
        return tempo.duration(of: note)
    }
    
    /// beats
    public var beats: MusicDuration {
        return tempo.beats(of: note)
    }
    
    /// note name
    public var noteName: String {
        return note.pitch.description
    }
    
    /// end beat
    public var endBeat: MusicTimeStamp {
        return beginBeat + beats
    }
    
    public var pitch: Pitch {
        return note.pitch
    }
}

extension NoteInScore: CustomStringConvertible {
    public var description: String {
        return String(format: "[%.3f-%.3f)", beginBeat, endBeat) + " "
        + "🎵\(note)" + " beats:\(beats.as3DigitString) duration:\(phyDuration.as3DigitString)" + " "
        + "⬇️\(performInfo?.pressVelocity ?? 0) ⬆️\(performInfo?.releaseVelocity ?? 0)" + " "
        + "᭶" + "\(tempo.bpm.as1DigitString)" + " " + "\(tempo.timeSignature)"
    }
}

/// hashable
extension NoteInScore: Hashable {
    public static func == (lhs: NoteInScore, rhs: NoteInScore) -> Bool {
        return lhs.beginBeat == rhs.beginBeat && lhs.note == rhs.note
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(beginBeat)
        hasher.combine(note.pitch.rawValue)
        hasher.combine(note.timeValue.rawValue)
    }
}

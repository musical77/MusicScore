
import Foundation
import AudioToolbox
import os

import MusicSymbol


/// music score
public struct MusicScore {
    
    public var name: String = "unknown"
    
    /// all voice part in this score
    public var musicParts : [MusicPart] = []
    
    ///
    public init?(url: URL) {
        guard let midi = MIDISequence(url: url) else {
            logger.error("failed to load midi sequence from \(url.description)")
            return nil
        }
        
        self.name = url.lastPathComponent
        self.midi = midi
        logger.info("\(url.description) music sound tracks without meta: \(midi.getNumberOfSoundTracks())")

        // extract tempos
        let tempoEvents = tempoParser.getTempoInScores(midi)
        for tempo in tempoEvents {
            logger.info("tempo: \(tempo)")
        }

        // extract music parts
        for idx in 0..<(midi.getNumberOfSoundTracks()) {
            let events = midi.getTrackEvents(trackIndex: idx)
            let part = MusicPart(id: MusicPartID(idx), named: self.name + "_\(idx)",
                                 with: tempoEvents, midiEvents: events)
            
            // skip empty track
            if part.notes.isEmpty {
                logger.warning("track \(idx), has no note events, skip it")
                continue
            }
            
            self.musicParts.append(part)
            logger.info("track \(idx), has notes: \(part.notes.count), instr: \(part.meta.instrument.description)")
        }
    }
    
    // MARK: private
    
    private var midi: MIDISequence
    
    private var logger = Logger(subsystem: "MusicScore", category: "MusicScore")
    private var tempoParser = TempoEventParser()
}


// read-only var
public extension MusicScore {
    
    var numberOfMeasures: Int {
        get {
            return musicParts.map { $0.measures.count }.max() ?? 0
        }
    }
    
    
    func musicPartOf(instrument: InstrumentType) -> MusicPart? {
        for part in musicParts {
            if part.meta.instrument == instrument {
                return part
            }
        }
        return nil
    }
    
    
    var duration: MusicDuration {
        get {
            return musicParts.map { $0.musicDuration }.max() ?? 0
        }
    }
}

/// cut
public extension MusicScore {
    
    /// 
    mutating func cut(beginBeat: MusicTimeStamp, endBeat: MusicTimeStamp) {
        for idx in 0..<self.musicParts.count {
            musicParts[idx].cut(beginBeat: beginBeat, endBeat: endBeat)
        }
    }
}

/// string ext
extension MusicScore: CustomStringConvertible {
    public var description: String {
        return "Score: \(name)\n" + musicParts.map { $0.description }.joined(separator: "\n")
    }
}

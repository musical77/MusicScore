
import Foundation
import AudioToolbox
import os

import MusicSymbol


/// music score
public struct MusicScore {
    
    public var name: String = "unknown"
    
    /// all voice part in this score
    public var musicParts : [MusicPart] = []
    
    /// init from url (midi file url)
    public init?(url: URL) {
        if let score = scoreParser.loadMusicScore(url: url) {
            self = score
        } else {
            return nil
        }
    }
    
    public init() {}
    
    // MARK: private
        
    private var logger = Logger(subsystem: "MusicScore", category: "MusicScore")
    private var scoreParser = MIDIScoreParser()
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

/// subset
public extension MusicScore {
    
    /// return MusicScore in [beginMeasureIdx, endMeasureIdx)
    func subset(beginMeasureIdx: Int, endMeasureIdx: Int) -> MusicScore {
        var newScore = self
        for idx in 0..<newScore.musicParts.count {
            let measures = Array<Measure>(self.musicParts[idx].measures[beginMeasureIdx..<endMeasureIdx])
            newScore.musicParts[idx].measures = measures
            newScore.musicParts[idx].notes = measures.flatMap { $0.notes }
        }
        return newScore
    }
    
    /// return MusicScore in [beginBeat, endBeat)
    func subset(beginBeat: MusicTimeStamp, endBeat: MusicTimeStamp) -> MusicScore {
        var newScore = self
        for idx in 0..<newScore.musicParts.count {
            newScore.musicParts[idx].notes = musicParts[idx].notes.filter {
                $0.beginBeat >= beginBeat && $0.beginBeat < endBeat
            }
            newScore.musicParts[idx].measures = musicParts[idx].measures.filter {
                $0.beginBeat >= beginBeat && $0.beginBeat < endBeat ||
                $0.endBeat >= beginBeat && $0.endBeat < endBeat
            }
        }
        return newScore
    }
}

/// string ext
extension MusicScore: CustomStringConvertible {
    public var description: String {
        return "Score: \(name)\n" + musicParts.map { $0.description }.joined(separator: "\n")
    }
}

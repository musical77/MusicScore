import Foundation
import MusicSymbol

///（measure/bar）
public struct Measure {

    ///
    public let index: Int

    /// notes in this measure
    public var notes: [NoteInScore]
    
    /// begin beat of this measure
    public let beginBeat: MusicTimeStamp
    
    /// end beat of this measure(not including)
    public let endBeat: MusicTimeStamp
    
    /// tempo
    public let tempo: TempoInScore
}

/// 
extension Measure {
    public var beats: Int {
        return tempo.timeSignature.beats
    }
    
    public subscript(idx: Int) -> [NoteInScore] {
        let localBeginBeat = beginBeat + Double(idx)
        let localEndBeat = localBeginBeat + 1
        return notes.filter { $0.beginBeat >= localBeginBeat && $0.beginBeat < localEndBeat }
    }
}



extension Measure: CustomStringConvertible {
    public var description: String {
        var result = "measure: \(index), [\(beginBeat), \(endBeat)), tempo: \(tempo)\n"
        result = result + notes.map { $0.description }.joined(separator: "\n")
        return result
    }
}

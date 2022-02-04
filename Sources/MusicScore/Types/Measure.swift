import Foundation
import MusicSymbol

///（measure/bar）
public struct Measure {
    public init(index: Int, notes: [NoteInScore], beginBeat: MusicTimeStamp, endBeat: MusicTimeStamp) {
        self.index = index
        self.notes = notes
        self.beginBeat = beginBeat
        self.endBeat = endBeat
    }

    ///
    public let index: Int

    /// notes in this measure
    public var notes: [NoteInScore]
    
    /// begin beat of this measure
    public let beginBeat: MusicTimeStamp
    
    /// end beat of this measure(not including)
    public let endBeat: MusicTimeStamp
}

/// 
extension Measure {
    public var beats: Int {
        return Int(endBeat - beginBeat + 1e-6)
    }
    
    /// return notes in idx beat in this measure
    public func notes(inBeat idx: Int) -> [NoteInScore] {
        let localBeginBeat = beginBeat + Double(idx)
        let localEndBeat = localBeginBeat + 1
        return notes.filter { $0.beginBeat >= localBeginBeat && $0.beginBeat < localEndBeat }
    }
}


/// 
extension Measure: CustomStringConvertible {
    public var description: String {
        var result = "measure: \(index), [\(beginBeat), \(endBeat))\n"
        result = result + notes.map { $0.description }.joined(separator: "\n")
        return result
    }
}

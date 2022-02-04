
import Foundation
import AudioToolbox

public typealias MusicTimeStampOfQuarters = Float64

/// Trying to ease the pain of uaing Core Audio.
/// midi event
struct TimedMIDIEvent {
    
    var eventType: MusicEventType
    var eventTimeStamp: MusicTimeStampOfQuarters
    
    /// midi note
    var midiNoteMessage: MIDINoteMessage? = nil
    
    /// meta
    var midiMetaEvent: MIDIMetaEvent? = nil
    var midiMetaEventTempo: MIDIMetaEventTempo? = nil
    
    /// channel message
    var midiChannelMessage: MIDIChannelMessage? = nil
    
    /// tempo event
    var tempoEvent: ExtendedTempoEvent? = nil
}

extension MIDIChannelMessage {
    /// 1100nnnn    0ppppppp    Program Change.
    /// This message sent when the patch number changes.
    /// (ppppppp) is the new program number.
    var programChange: Int? {
        if self.status >= 192 && self.status < 192 + 16 {
            return Int(self.data1)
        }
        return nil
    }
    
    /// 1011nnnn    0ccccccc 0vvvvvvv
    var controllerMessage: (UInt8, UInt8)? {
        if self.status >= 11 * 16 && self.status < 12 * 16 {
            return (self.data1, self.data2)
        }
        return nil
    }
    
    /// <63=off    >64=on
    var pedalStatus: Bool? {
        if let message = controllerMessage {
            if message.0 == 64 {
                return message.1 > 64
            }
        }
        return nil
    }
}

// MARK: meta extension

public struct MIDIMetaEventTempo {
    init(metaEventType: UInt8, unused1: UInt8, unused2: UInt8, unused3: UInt8, dataLength: UInt32,
         nn: UInt8, dd: UInt8, cc: UInt8, bb: UInt8) {
        self.metaEventType = metaEventType
        self.unused1 = unused1
        self.unused2 = unused2
        self.unused3 = unused3
        self.dataLength = dataLength
        self.nn = nn
        self.dd = dd
        self.cc = cc
        self.bb = bb
    }
    

    public var metaEventType: UInt8
    public var unused1: UInt8
    public var unused2: UInt8
    public var unused3: UInt8

    public var dataLength: UInt32

    public var nn: UInt8
    public var dd: UInt8
    public var cc: UInt8
    public var bb: UInt8

}


//
//  MIDISequence.swift
//  MusicSequence
//
//  Created by Gene De Lisa on 8/17/14.
//  Copyright (c) 2014 Gene De Lisa. All rights reserved.

import Foundation
import AudioToolbox
import os

class MIDISequence {
    
    private var musicSequence: MusicSequence? = nil
    
    init?(url: URL) {
        if NewMusicSequence(&musicSequence) != OSStatus(noErr) {
            os_log(.error, "failed to create new music sequence")
            return nil
        }
        
        /// If this flag is set the resultant Sequence will contain a tempo track,
        /// 1 track for each MIDI Channel that is found in the SMF, 1 track for SysEx or MetaEvents -
        /// and this will be the last track in the sequence after the LoadSMFWithFlags calls.
        let flags = MusicSequenceLoadFlags.smf_ChannelsToTracks ///
        let typeid = MusicSequenceFileTypeID.midiType  ///
        let status = MusicSequenceFileLoad(musicSequence!, url as CFURL, typeid, flags)
        
        if status != OSStatus(noErr) {
            os_log(.error, "failed to load from %s", url.description)
            return nil
        }
    }
    
    /// return number of tracks excluding the metaevents track
    func getNumberOfSoundTracks() -> Int {
        var trackCount : UInt32 = 0
        let status = MusicSequenceGetTrackCount(musicSequence!, &trackCount)
        if status != OSStatus(noErr) {
            return -1
        }
        return Int(trackCount) - 1
    }
    
    ///
    func getTrackEvents(trackIndex: Int) -> [TimedMIDIEvent] {
        if let track = self.getTrack(trackIndex: trackIndex) {
            return getTrackEvents(track: track)
        }
        return []
    }
    
    ///
    func getTempoTrackEvents() -> [TimedMIDIEvent] {
        if let track = self.getTempoTrack() {
            return getTrackEvents(track: track)
        }
        return []
    }
    
    ///
    func getMetaEvents() -> [TimedMIDIEvent] {
        return getTrackEvents(trackIndex: getNumberOfSoundTracks())
    }
    
    /// begin private functions
    
    private func getTrackEvents(track: MusicTrack) -> [TimedMIDIEvent] {
        var iterator: MusicEventIterator? = nil
        var status = OSStatus(noErr)
        status = NewMusicEventIterator(track, &iterator)
        if status != OSStatus(noErr) {
            return []
        }
        
        var hasCurrentEvent: DarwinBoolean = false
        status = MusicEventIteratorHasCurrentEvent(iterator!, &hasCurrentEvent)
        if status != OSStatus(noErr) {
            return []
        }
        
        var eventType:MusicEventType = 0
        var eventTimeStamp:MusicTimeStamp = -1
        var eventData: UnsafeRawPointer? = nil
        var eventDataSize: UInt32 = 0
        var results: [TimedMIDIEvent] = []
        while (hasCurrentEvent.boolValue) {
            status = MusicEventIteratorGetEventInfo(
                iterator!, &eventTimeStamp, &eventType, &eventData, &eventDataSize)
            
            if status != OSStatus(noErr) {
                os_log(.error, "bad status %s getting event info", status.description)
                break
            }
            
            switch UInt32(eventType) {
            case kMusicEventType_MIDINoteMessage:
                let data = eventData!.bindMemory(to: MIDINoteMessage.self, capacity: Int(eventDataSize))
                results.append(TimedMIDIEvent(eventType: eventType, eventTimeStamp: eventTimeStamp,
                                              midiNoteMessage: data.pointee))
                break
                
            case kMusicEventType_Meta:
                let data = eventData!.bindMemory(to: MIDIMetaEvent.self, capacity: Int(eventDataSize))
                let midiEvent = data.pointee
                let event = TimedMIDIEvent(eventType: eventType,
                                           eventTimeStamp: eventTimeStamp,
                                           midiMetaEvent: midiEvent)
                
                // meta event
                if midiEvent.metaEventType == 0x58 {
                    let midiEventTempo = eventData!.bindMemory(to: MIDIMetaEventTempo.self, capacity: Int(eventDataSize)).pointee
                    let tempoEvent = TimedMIDIEvent(eventType: eventType, eventTimeStamp: eventTimeStamp,
                                                    midiMetaEventTempo: midiEventTempo)
                    results.append(tempoEvent)
                } else {
                    results.append(event)
                }
                break
                
            case kMusicEventType_MIDIChannelMessage :
                let data = eventData!.bindMemory(to: MIDIChannelMessage.self, capacity: Int(eventDataSize))
                results.append(TimedMIDIEvent(eventType: eventType, eventTimeStamp: eventTimeStamp,
                                              midiChannelMessage: data.pointee))
                break
                
            case kMusicEventType_ExtendedTempo:
                let data = eventData!.bindMemory(to: ExtendedTempoEvent.self, capacity: Int(eventDataSize))
                results.append(TimedMIDIEvent(eventType: eventType, eventTimeStamp: eventTimeStamp,
                                              tempoEvent: data.pointee))
                break
                
            default:
                os_log(.error, "Something or other: %d", eventType)
            }
            
            status = MusicEventIteratorHasNextEvent(iterator!, &hasCurrentEvent)
            if status != OSStatus(noErr) {
                os_log(.error, "bad status %s checking for next event", status.description)
                break
            }
            
            status = MusicEventIteratorNextEvent(iterator!)
            if status != OSStatus(noErr) {
                os_log(.error, "bad status %s going to next event", status.description)
                break
            }
        }
        return results
    }
    
    private func getTrack(trackIndex:Int) -> MusicTrack? {
        var track: MusicTrack? = nil
        let status = MusicSequenceGetIndTrack(musicSequence!, UInt32(trackIndex), &track)
        if status != OSStatus(noErr) {
            os_log(.error, "failed to get track: %d", trackIndex)
            return nil
        }
        return track
    }
    
    private func getTempoTrack() -> MusicTrack? {
        var track: MusicTrack? = nil
        let status = MusicSequenceGetTempoTrack(musicSequence!, &track)
        if status != OSStatus(noErr) {
            os_log(.error, "failed to get tempo track")
            return nil
        }
        return track
    }
    
}

/**
 //
 //            case kMusicEventType_ExtendedNote:
 //                let data = UnsafePointer<ExtendedNoteOnEvent>(eventData)
 //                let event = data.memory
 //                var te = TimedMIDIEvent(eventType: eventType, eventTimeStamp: eventTimeStamp, event: event)
 //                results.append(te)
 //                break
 //
 
 //
 //            case kMusicEventType_User:
 //                let data = UnsafePointer<MusicEventUserData>(eventData)
 //                let event = data.memory
 //                var te = TimedMIDIEvent(eventType: eventType, eventTimeStamp: eventTimeStamp, event: event)
 //                results.append(te)
 //                break
 //
 //
 //            case kMusicEventType_MIDIRawData :
 //                let data = UnsafePointer<MIDIRawData>(eventData)
 //                let raw = data.memory
 //                var te = TimedMIDIEvent(eventType: eventType, eventTimeStamp: eventTimeStamp, event: raw)
 //                results.append(te)
 //                break
 //
 //            case kMusicEventType_Parameter :
 //                let data = UnsafePointer<ParameterEvent>(eventData)
 //                let param = data.memory
 //                var te = TimedMIDIEvent(eventType: eventType, eventTimeStamp: eventTimeStamp, event: param)
 //                results.append(te)
 //                break
 */


//
//    func addNoteToTrack(trackIndex:Int, beat:Float, channel:Int, note:Int, velocity:Int, releaseVelocity:Int, duration:Float) {
//        var track = getTrack(trackIndex)
//        addNoteToTrack(track, beat: beat, channel: channel, note: note, velocity: velocity, releaseVelocity: releaseVelocity, duration: duration)
//    }
//
//    func addNoteToTrack(track:MusicTrack, beat:Float, channel:Int, note:Int, velocity:Int, releaseVelocity:Int, duration:Float) {
//
//        var mess = MIDINoteMessage(channel: UInt8(channel), note: UInt8(note), velocity: UInt8(velocity), releaseVelocity: UInt8(releaseVelocity), duration: Float32(duration))
//
//        var status = OSStatus(noErr)
//        status = MusicTrackNewMIDINoteEvent(track, MusicTimeStamp(beat), &mess)
//        if status != OSStatus(noErr) {
//            println("bad status \(status) creating note event")
//            displayStatus(status)
//        }
//
//    }
//
//    func addChannelMessageToTrack(trackIndex:Int, beat:Float, channel:Int, status:Int, data1:Int, data2:Int, reserved:Int) {
//        var track = getTrack(trackIndex)
//        addChannelMessageToTrack(track, beat: beat, channel: channel, status: status, data1: data1, data2: data2, reserved: reserved)
//    }
//
//    func addChannelMessageToTrack(track:MusicTrack, beat:Float, channel:Int, status:Int, data1:Int, data2:Int, reserved:Int) {
//        var mess = MIDIChannelMessage(status: UInt8(status), data1: UInt8(data1), data2: UInt8(data2), reserved: UInt8(reserved))
//        var status = OSStatus(noErr)
//        status = MusicTrackNewMIDIChannelEvent(track, MusicTimeStamp(beat), &mess)
//        if status != OSStatus(noErr) {
//            println("bad status \(status) creating channel event")
//            displayStatus(status)
//        }
//    }
//
//    func display()  {
//        var status = OSStatus(noErr)
//
//        var trackCount:UInt32 = 0
//        status = MusicSequenceGetTrackCount(self.musicSequence, &trackCount)
//
//        if status != OSStatus(noErr) {
//            displayStatus(status)
//
//            println("in display: getting track count")
//        }
//        println("There are \(trackCount) tracks")
//
//        var track:MusicTrack = nil
//        for var i:UInt32 = 0; i < trackCount; i++ {
//            status = MusicSequenceGetIndTrack(self.musicSequence, i, &track)
//
//            if status != OSStatus(noErr) {
//                displayStatus(status)
//
//            }
//            println("\n\nTrack \(i)")
//
//            // getting track properties is ugly
//
//            var trackLength:MusicTimeStamp = -1
//            var prop:UInt32 = UInt32(kSequenceTrackProperty_TrackLength)
//            // the size is filled in by the function
//            var size:UInt32 = 0
//            status = MusicTrackGetProperty(track, prop, &trackLength, &size)
//            if status != OSStatus(noErr) {
//                println("bad status \(status)")
//            }
//            println("track length \(trackLength)")
//
//            var loopInfo:MusicTrackLoopInfo = MusicTrackLoopInfo(loopDuration: 0,numberOfLoops: 0)
//            prop = UInt32(kSequenceTrackProperty_LoopInfo)
//            status = MusicTrackGetProperty(track, prop, &loopInfo, &size)
//            if status != OSStatus(noErr) {
//                println("bad status \(status)")
//            }
//            println("loop info \(loopInfo.loopDuration)")
//
//            iterate(track)
//        }
//
//        CAShow(UnsafeMutablePointer<MusicSequence>(musicSequence))
//
//    }
//    /**
//    Itereates over a MusicTrack and prints the MIDI events it contains.
//
//    :param: track:MusicTrack the track to iterate
//    */
//    func iterate(track:MusicTrack) {
//        var    iterator:MusicEventIterator = nil
//        var status = OSStatus(noErr)
//        status = NewMusicEventIterator(track, &iterator)
//        if status != OSStatus(noErr) {
//            println("bad status \(status)")
//        }
//
//        var hasCurrentEvent:Boolean = 0
//        status = MusicEventIteratorHasCurrentEvent(iterator, &hasCurrentEvent)
//        if status != OSStatus(noErr) {
//            println("bad status \(status)")
//        }
//
//        var eventType:MusicEventType = 0
//        var eventTimeStamp:MusicTimeStamp = -1
//        var eventData: UnsafePointer<()> = nil
//        var eventDataSize:UInt32 = 0
//
//        while (hasCurrentEvent != 0) {
//            status = MusicEventIteratorGetEventInfo(iterator, &eventTimeStamp, &eventType, &eventData, &eventDataSize)
//            if status != OSStatus(noErr) {
//                println("bad status \(status)")
//            }
//
//            switch Int(eventType) {
//            case kMusicEventType_MIDINoteMessage:
//                let data = UnsafePointer<MIDINoteMessage>(eventData)
//                let note = data.memory
//                println("Note message \(note.note), vel \(note.velocity) dur \(note.duration) at time \(eventTimeStamp)")
//                break
//
//            case kMusicEventType_ExtendedNote:
//                let data = UnsafePointer<ExtendedNoteOnEvent>(eventData)
//                let event = data.memory
//                println("ext note message")
//                break
//
//            case kMusicEventType_ExtendedTempo:
//                let data = UnsafePointer<ExtendedTempoEvent>(eventData)
//                let event = data.memory
//                println("ext tempo message")
//                NSLog("ExtendedTempoEvent, bpm %f", event.bpm)
//
//                break
//
//            case kMusicEventType_User:
//                let data = UnsafePointer<MusicEventUserData>(eventData)
//                let event = data.memory
//                println("user message")
//                break
//
//            case kMusicEventType_Meta:
//                let data = UnsafePointer<MIDIMetaEvent>(eventData)
//                let event = data.memory
//                println("meta message \(event.metaEventType)")
//                break
//
//            case kMusicEventType_MIDIChannelMessage :
//                let data = UnsafePointer<MIDIChannelMessage>(eventData)
//                let cm = data.memory
//                NSLog("channel event status %X", cm.status)
//                NSLog("channel event d1 %X", cm.data1)
//                NSLog("channel event d2 %X", cm.data2)
//                if (cm.status == (0xC0 & 0xF0)) {
//                    println("preset is \(cm.data1)")
//                }
//                break
//
//            case kMusicEventType_MIDIRawData :
//                let data = UnsafePointer<MIDIRawData>(eventData)
//                let raw = data.memory
//                NSLog("MIDIRawData i.e. SysEx, length %lu", raw.length)
//                break
//
//            case kMusicEventType_Parameter :
//                let data = UnsafePointer<ParameterEvent>(eventData)
//                let param = data.memory
//                NSLog("ParameterEvent, parameterid %lu", param.parameterID)
//                break
//
//            default:
//                println("something or other \(eventType)")
//            }
//
//            status = MusicEventIteratorHasNextEvent(iterator, &hasCurrentEvent)
//            if status != OSStatus(noErr) {
//                println("bad status \(status)")
//            }
//
//            status = MusicEventIteratorNextEvent(iterator)
//            if status != OSStatus(noErr) {
//                println("bad status \(status)")
//            }
//        }
//    }
//
//    /**
//    Just for testing. Uses a sine wave.
//    */
//    func play() {
//        var status = OSStatus(noErr)
//
//        var musicPlayer:MusicPlayer = nil
//        status = NewMusicPlayer(&musicPlayer)
//        if status != OSStatus(noErr) {
//            println("bad status \(status) creating player")
//            displayStatus(status)
//            return
//        }
//
//        status = MusicPlayerSetSequence(musicPlayer, self.musicSequence)
//        if status != OSStatus(noErr) {
//            displayStatus(status)
//            println("setting sequence")
//            return
//        }
//
//        status = MusicPlayerPreroll(musicPlayer)
//        if status != OSStatus(noErr) {
//            displayStatus(status)
//            return
//        }
//
//        status = MusicPlayerStart(musicPlayer)
//        if status != OSStatus(noErr) {
//            displayStatus(status)
//            return
//        }
//    }
//
//
//    func displayStatus(status:OSStatus) {
//        println("Bad status: \(status)")
//        var nserror = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
//        println("\(nserror.localizedDescription)")
//
//        switch status {
//            // ugly
//        case OSStatus(kAudioToolboxErr_InvalidSequenceType):
//            println("Invalid sequence type")
//
//        case OSStatus(kAudioToolboxErr_TrackIndexError):
//            println("Track index error")
//
//        case OSStatus(kAudioToolboxErr_TrackNotFound):
//            println("Track not found")
//
//        case OSStatus(kAudioToolboxErr_EndOfTrack):
//            println("End of track")
//
//        case OSStatus(kAudioToolboxErr_StartOfTrack):
//            println("start of track")
//
//        case OSStatus(kAudioToolboxErr_IllegalTrackDestination):
//            println("Illegal destination")
//
//        case OSStatus(kAudioToolboxErr_NoSequence):
//            println("No Sequence")
//
//        case OSStatus(kAudioToolboxErr_InvalidEventType):
//            println("Invalid Event Type")
//
//        case OSStatus(kAudioToolboxErr_InvalidPlayerState):
//            println("Invalid Player State")
//
//        case OSStatus(kAudioToolboxErr_CannotDoInCurrentContext):
//            println("Cannot do in current context")
//
//        default:
//            println("Something or other went wrong")
//        }
//    }

//
//func FromBuf(ptr: UnsafePointer<UInt8>, length len: Int) -> String? {
//    // convert the bytes using the UTF8 encoding
//    if let theString = NSString(bytes: ptr, length: len, encoding: String.Encoding.utf8.rawValue) {
//        return theString as String
//    } else {
//        return nil // the bytes aren't valid UTF8
//    }
//}
//
//extension MIDIMetaEvent {
//    var message: String? {
//        mutating get {
//            var result: String?
//            withUnsafePointer(to: &data) { pointer in
//                result = FromBuf(ptr: pointer, length: Int(dataLength))
//            }
//            return result
//        }
//    }
//}



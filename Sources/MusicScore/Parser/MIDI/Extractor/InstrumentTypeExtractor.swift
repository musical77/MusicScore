
import os
import Foundation
import MusicSymbol

/// instrument type
public extension InstrumentType {
    
    /// from midi program number
    init(programNumber: Int) {
        self = .unknown
        if programNumber == 40 { /// violin
            self = .violin
        }
        if programNumber == 0 || programNumber == 1 { /// piano
            self = .piano
        }
        if programNumber == 14 {
            self = .tubular_bells
        }
        if programNumber == 9 {
            self = .glock
        }
    }
}

class InstrumentTypeExtractor {
    func getInstrument(midiEvents: [TimedMIDIEvent]) -> InstrumentType {
        for event in midiEvents {
            if let channelMessage = event.midiChannelMessage {
//                logger.debug("\(event.eventTimeStamp.asMusicTimeDescription), status: \(channelMessage.status)")
                if let programNumber = channelMessage.programChange {
//                    logger.debug("\(event.eventTimeStamp.asMusicTimeDescription), found instrument: \(programNumber)")
                    return InstrumentType(programNumber: programNumber)
                }
            }
        }
        return .unknown
    }
    
    private var logger = Logger(subsystem: "MusicScore", category: "InstrumentTypeExtractor")
}

/**
 Instrument Map
 PC#    Instrument    PC#    Instrument
 1.    Acoustic Grand Piano    65.    Soprano Sax
 2.    Bright Acoustic Piano    66.    Alto Sax
 3.    Electric Grand Piano    67.    Tenor Sax
 4.    Honky-tonk Piano    68.    Baritone Sax
 5.    Electric Piano 1 (Rhodes Piano)    69.    Oboe
 6.    Electric Piano 2 (Chorused Piano)    70.    English Horn
 7.    Harpsichord    71.    Bassoon
 8.    Clavinet    72.    Clarinet
 9.    Celesta    73.    Piccolo
 10.    Glockenspiel    74.    Flute
 11.    Music Box    75.    Recorder
 12.    Vibraphone    76.    Pan Flute
 13.    Marimba    77.    Blown Bottle
 14.    Xylophone    78.    Shakuhachi
 15.    Tubular Bells    79.    Whistle
 16.    Dulcimer (Santur)    80.    Ocarina
 17.    Drawbar Organ (Hammond)    81.    Lead 1 (square wave)
 18.    Percussive Organ    82.    Lead 2 (sawtooth wave)
 19.    Rock Organ    83.    Lead 3 (calliope)
 20.    Church Organ    84.    Lead 4 (chiffer)
 21.    Reed Organ    85.    Lead 5 (charang)
 22.    Accordion (French)    86.    Lead 6 (voice solo)
 23.    Harmonica    87.    Lead 7 (fifths)
 24.    Tango Accordion (Band neon)    88.    Lead 8 (bass + lead)
 25.    Acoustic Guitar (nylon)    89.    Pad 1 (new age Fantasia)
 26.    Acoustic Guitar (steel)    90.    Pad 2 (warm)
 27.    Electric Guitar (jazz)    91.    Pad 3 (polysynth)
 28.    Electric Guitar (clean)    92.    Pad 4 (choir space voice)
 29.    Electric Guitar (muted)    93.    Pad 5 (bowed glass)
 30.    Overdriven Guitar    94.    Pad 6 (metallic pro)
 31.    Distortion Guitar    95.    Pad 7 (halo)
 32.    Guitar harmonics    96.    Pad 8 (sweep)
 33.    Acoustic Bass    97.    FX 1 (rain)
 34.    Electric Bass (fingered)    98.    FX 2 (soundtrack)
 35.    Electric Bass (picked)    99.    FX 3 (crystal)
 36.    Fretless Bass    100.    FX 4 (atmosphere)
 37.    Slap Bass 1    101.    FX 5 (brightness)
 38.    Slap Bass 2    102.    FX 6 (goblins)
 39.    Synth Bass 1    103.    FX 7 (echoes, drops)
 40.    Synth Bass 2    104.    FX 8 (sci-fi, star theme)
 41.    Violin    105.    Sitar
 42.    Viola    106.    Banjo
 43.    Cello    107.    Shamisen
 44.    Contrabass    108.    Koto
 45.    Tremolo Strings    109.    Kalimba
 46.    Pizzicato Strings    110.    Bag pipe
 47.    Orchestral Harp    111.    Fiddle
 48.    Timpani    112.    Shanai
 49.    String Ensemble 1 (strings)    113.    Tinkle Bell
 50.    String Ensemble 2 (slow strings)    114.    Agogo
 51.    SynthStrings 1    115.    Steel Drums
 52.    SynthStrings 2    116.    Woodblock
 53.    Choir Aahs    117.    Taiko Drum
 54.    Voice Oohs    118.    Melodic Tom
 55.    Synth Voice    119.    Synth Drum
 56.    Orchestra Hit    120.    Reverse Cymbal
 57.    Trumpet    121.    Guitar Fret Noise
 58.    Trombone    122.    Breath Noise
 59.    Tuba    123.    Seashore
 60.    Muted Trumpet    124.    Bird Tweet
 61.    French Horn    125.    Telephone Ring
 62.    Brass Section    126.    Helicopter
 63.    SynthBrass 1    127.    Applause
 64.    SynthBrass 2    128.    Gunshot
 */
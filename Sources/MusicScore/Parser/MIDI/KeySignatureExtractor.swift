//  KeySignatureExtractor.swift
//  
//
//  Created by lively77 on 2022/2/11.
//

import Foundation
import MusicSymbol
import MidiParser

class KeySignatureExtractor {
    func getKeySignatures(noteTrack: MidiNoteTrack) -> [(MusicTimeStampOfQuarters, KeySignature)] {
        let keySigns = noteTrack.keySignatures
        return Array(keySigns.map { ($0.timeStamp, $0.keySig) })
    }
}

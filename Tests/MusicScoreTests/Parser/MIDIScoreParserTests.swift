//
//  MIDIScoreParserTests.swift
//  
//
//  Created by lively77 on 2022/2/9.
//

import Foundation
import MusicScore
import XCTest

class MIDIScoreParserTests : XCTestCase {
    func testScoreLoadFromURL() {
       
        let score1 = MIDIScoreParser().loadMusicScore(url: ScoreSamples.url_spring1st)!
        print(score1)
    }
}

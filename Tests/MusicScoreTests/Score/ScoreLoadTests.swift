//  MusicScoreTests.swift
//  MusicScore
//
//  Copyright © 2022 live77. All rights reserved.

import XCTest
import MusicScore

class ScoreLoadTests: XCTestCase {
    
    /// test read music score basic info
    func testScoreLoad1() {
        let score = ScoreSamples.spring1st

        /// music part
        XCTAssertEqual(score.musicParts.count, 2)
        XCTAssertNotNil(score.musicPartOf(instrument: .piano))
        XCTAssertNotNil(score.musicPartOf(instrument: .violin))

        /// tempo changes
//        XCTAssertEqual(score.tempos.count, 1)
//        XCTAssertEqual(score.tempos[0].timeSignature.beats, 4)
//        XCTAssertEqual(score.tempos[0].timeSignature.noteTimeValue, .quarter)
    }
    
    /// test read music score basic info
    func testScoreLoad2() {
        let score = ScoreSamples.chopin92
        
        XCTAssertEqual(score.musicParts.count, 1)
        XCTAssertNotNil(score.musicPartOf(instrument: .piano))
        
//        XCTAssertEqual(score.tempos[0].timeSignature.beats, 1)
//        XCTAssertEqual(score.tempos[0].timeSignature.noteTimeValue, .eighth)
//
//        XCTAssertEqual(score.tempos[1].timeSignature.beats, 12)
//        XCTAssertEqual(score.tempos[1].timeSignature.noteTimeValue, .eighth)
//        XCTAssertEqual(score.tempos[1].beginBeat, 0.5)
        
        // tempo
//        for idx in 0..<score.tempos.count - 1 {
//            XCTAssertEqual(score.tempos[idx].endBeat, score.tempos[idx + 1].beginBeat)
//        }
    }
    
    /// test read music score basic info
    func testScoreLoad3() {
        let score = ScoreSamples.sonataPathetique
        
        XCTAssertEqual(score.musicParts.count, 1)
        XCTAssertNotNil(score.musicPartOf(instrument: .piano))
        
        let pianoPart = score.musicPartOf(instrument: .piano)!
        XCTAssertEqual(73, pianoPart.measures.count)
        
        print(pianoPart.measures[0])
    }
    
   
    func testScoreLoadFromURL() {
        let score = MusicScore(url: ScoreSamples.url_spring1st)!
        print(score)
    }
}


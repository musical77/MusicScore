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
        XCTAssertEqual(score.musicParts.count, 3)
        XCTAssertEqual(score.musicPartOf(instrumentFamily: .piano).count, 2)
        XCTAssertEqual(score.musicPartOf(instrumentFamily: .strings).count, 1)

        /// tempo changes
        XCTAssertEqual(score.musicParts[0].notes[0].tempo.timeSignature.beats, 4)
        XCTAssertEqual(score.musicParts[0].notes[0].tempo.timeSignature.noteTimeValue, .quarter)
    }
    
    /// test read music score basic info
    func testScoreLoad2() {
        let score = ScoreSamples.chopin92
        
        XCTAssertEqual(score.musicParts.count, 2)
        XCTAssertEqual(score.musicPartOf(instrument: .acousticGrand).count, 2)
        
        XCTAssertEqual(score.musicParts[0].notes[0].tempo.timeSignature.beats, 1)
        XCTAssertEqual(score.musicParts[0].notes[0].tempo.timeSignature.noteTimeValue, .eighth)
        
        XCTAssertEqual(score.musicParts[0].notes[1].tempo.timeSignature.beats, 12)
        XCTAssertEqual(score.musicParts[0].notes[1].tempo.timeSignature.noteTimeValue, .eighth)
    }
    
    /// test read music score basic info
    func testScoreLoad3() {
        let score = ScoreSamples.sonataPathetique
        
        XCTAssertEqual(score.musicParts.count, 2)
        XCTAssertEqual(score.musicPartOf(instrument: .acousticGrand).count, 2)
        
        let pianoPartRight = score.musicPartOf(instrument: .acousticGrand)[0]
        XCTAssertEqual(73, pianoPartRight.measures.count)
        
        let pianoPartLeft = score.musicPartOf(instrument: .acousticGrand)[1]
        XCTAssertEqual(73, pianoPartLeft.measures.count)
        
        print(pianoPartRight.measures[0])
        print(pianoPartLeft.measures[0])
        XCTAssertEqual(pianoPartLeft.measures[0].notes.count, 2)
        XCTAssertEqual(pianoPartRight.measures[0].notes.count, 10)
    }
    
    /// test read music score
    func testScoreLoad4() {
        let score = ScoreSamples.dreamingTrumerei
        XCTAssertEqual(score.numberOfMeasures, 33)
    }
    
   
    func testScoreLoadFromURL() {
        let score = MusicScore(url: ScoreSamples.url_spring1st)!
        print(score)
    }
}


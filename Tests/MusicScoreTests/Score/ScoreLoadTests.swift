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
        XCTAssertEqual(score.musicParts[0].notes[0].tempo.timeSignature.beats, 4)
        XCTAssertEqual(score.musicParts[0].notes[0].tempo.timeSignature.noteTimeValue, .quarter)
    }
    
    /// test read music score basic info
    func testScoreLoad2() {
        let score = ScoreSamples.chopin92
        
        XCTAssertEqual(score.musicParts.count, 1)
        XCTAssertNotNil(score.musicPartOf(instrument: .piano))
        
        XCTAssertEqual(score.musicParts[0].notes[0].tempo.timeSignature.beats, 1)
        XCTAssertEqual(score.musicParts[0].notes[0].tempo.timeSignature.noteTimeValue, .eighth)
        
        XCTAssertEqual(score.musicParts[0].notes[1].tempo.timeSignature.beats, 12)
        XCTAssertEqual(score.musicParts[0].notes[1].tempo.timeSignature.noteTimeValue, .eighth)
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


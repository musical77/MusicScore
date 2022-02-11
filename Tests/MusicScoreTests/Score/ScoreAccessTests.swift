//  MusicScoreTests.swift
//  MusicScore
//
//  Copyright © 2022 live77. All rights reserved.

import XCTest
import MusicSymbol
import MusicScore

class ScoreAccessTests: XCTestCase {
    
    /// test read music score , note name is correct?
    func testReadNoteName1() {
        let score = ScoreSamples.spring1st

        // mi in F major, first note , A6
        XCTAssertEqual(score.musicParts[0].notes.count, 1856)
        XCTAssertEqual(score.musicParts[0].notes[0].noteName, "A5")
        
        print(score.musicParts[0].notes[0].description)

        XCTAssertEqual(score.musicParts[0].notes[0].beats, 2)
    }
    
    /// test read note and check its tempo
    func testReadNoteTempo1() {
        let score = ScoreSamples.spring1st
        
        for note in score.musicParts[0].notes {
            XCTAssertEqual(note.tempo.timeSignature, "4/4")
            XCTAssertEqual(note.tempo.bpm, 120)
        }
    }
    
    /// test read measures
    func testGetMeasures1() {
        let score = ScoreSamples.spring1st

        XCTAssertEqual(score.musicParts[0].measures.count, 332)
        XCTAssertEqual(score.musicParts[1].measures.count, 332)

        XCTAssertEqual(score.numberOfMeasures, 332)
    }
    
    /// test read measures
    func testGetMeasures2() {
        let score = ScoreSamples.chopin92
        
        print(score.numberOfMeasures)
        
        print(score.musicPartOf(instrument: .acousticGrand)[0].measures[0])
        print(score.musicPartOf(instrument: .acousticGrand)[0].measures[1])
    }
    
    /// test music part access measures
    func testMusicPartSubscript() {
        let score = ScoreSamples.sonataPathetique
        
        let part = score.musicPartOf(instrument: .acousticGrand)[0]
        
        XCTAssertEqual(part.measures[0].beats, 2)
        XCTAssertEqual(part.measures[0].notes(inBeat: 0).count, 5)
        print(part.measures[0])
        print(part.measures[1])
    }

    /// test description
    func testGetMusicPartDesc1() {
        let score = ScoreSamples.chopin92
        
        XCTAssertEqual(score.musicParts[0].measures[0].description, """
measure: 0, [0.0, 1.0)
[0.000-1.000) 🎵A♯4 1/8 beats:1.000 duration:1.000 ⬇️65 ⬆️0
""")
        
        print("#musicParts: ", score.musicParts.count)
        XCTAssertEqual(score.musicParts.count, 2)
        
        print("first note: ", score.musicParts[0].measures[0].notes[0])
        XCTAssertEqual(score.musicParts[0].measures[0].notes[0].pitch, "A#4")
        XCTAssertEqual(score.musicParts[0].measures[0].notes.count, 1)
        
        print("first measure: ", score.musicParts[0].measures[1])
        XCTAssertEqual(score.musicParts[0].measures[1].notes.count, 6)
        XCTAssertEqual(score.musicParts[1].measures[1].notes.count, 24)
    }
    
    func testSpring1stCorrectness() {
        let score = ScoreSamples.spring1st
        
        XCTAssertEqual(score.musicParts.count, 3)
        
        let pianoPart = score.musicPartOf(instrument: .acousticGrand)[0]
        let violinPart = score.musicPartOf(instrument: .tremoloStrings)[0]
        
        print("first measure of the violin part: ", violinPart.measures[0])
        print("first measure of piano part: ", pianoPart.measures[0])
        print("first note in violin part: ", violinPart.measures[0].notes[0])
        
        print(score)
    }
    
}

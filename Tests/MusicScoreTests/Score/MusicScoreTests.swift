//  MusicScoreTests.swift
//  MusicScore
//
//  Copyright © 2022 live77. All rights reserved.

import XCTest
import MusicScore

class MusicScoreTests: XCTestCase {
    
    /// test read music score basic info
    func testScoreLoad1() {
        let score = ScoreSamples.spring1st

        /// music part
        XCTAssertEqual(score.musicParts.count, 2)
        XCTAssertNotNil(score.musicPartOf(instrument: .piano))
        XCTAssertNotNil(score.musicPartOf(instrument: .violin))

        /// tempo changes
        XCTAssertEqual(score.tempos.count, 1)
        XCTAssertEqual(score.tempos[0].timeSignature.beats, 4)
        XCTAssertEqual(score.tempos[0].timeSignature.noteTimeValue, .quarter)
    }
    
    /// test read music score basic info
    func testScoreLoad2() {
        let score = ScoreSamples.chopin92
        
        XCTAssertEqual(score.musicParts.count, 1)
        XCTAssertNotNil(score.musicPartOf(instrument: .piano))
        
        XCTAssertEqual(score.tempos[0].timeSignature.beats, 1)
        XCTAssertEqual(score.tempos[0].timeSignature.noteTimeValue, .eighth)
        
        XCTAssertEqual(score.tempos[1].timeSignature.beats, 12)
        XCTAssertEqual(score.tempos[1].timeSignature.noteTimeValue, .eighth)
        XCTAssertEqual(score.tempos[1].beginBeat, 0.5)
        
        // tempo
        for idx in 0..<score.tempos.count - 1 {
            XCTAssertEqual(score.tempos[idx].endBeat, score.tempos[idx + 1].beginBeat)
        }
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
    
    /// test read music score , note name is correct?
    func testReadNoteName1() {
        let score = ScoreSamples.spring1st

        // mi in F major, first note , A6
        XCTAssertEqual(score.musicParts[0].notes.count, 1856)
        XCTAssertEqual(score.musicParts[0].notes[0].noteName, "A5")
        
        print(score.musicParts[0].notes[0].description)

        XCTAssertEqual(score.musicParts[0].notes[0].beats, 2)
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
        
        print(score.musicPartOf(instrument: .piano)!.measures[0])
        print(score.musicPartOf(instrument: .piano)!.measures[1])
    }
    
    /// test music part subscript
    func testMusicPartSubscript() {
        let score = ScoreSamples.sonataPathetique
        
        let part = score.musicPartOf(instrument: .piano)!
        
        XCTAssertEqual(part[0].beats, 2)
        XCTAssertEqual(part[0][0].count, 6)
        print(part[0])
        print(part[1])
    }
    
    /// test music score subscript
    func testMusicPartSubscript2() {
        let score = ScoreSamples.sonataPathetique
        
        let part = score.musicPartOf(instrument: .piano)!
        
        let notes = part[0.0, 1.0]
        print(notes)
    }

    /// test description
    func testGetMusicPartDesc1() {
        let score = ScoreSamples.chopin92
        
        XCTAssertEqual(score.musicParts[0].measures[0].description, """
measure: 0, [0.0, 0.5), tempo: [0.000, 0.500) 🎼1/8 bpm:60
[0.000-0.500) 🎵A♯4 1/16 beats:0.500 duration:0.500 ⬇️65 ⬆️0
""")
        
        print("#musicParts: ", score.musicParts.count)
        XCTAssertEqual(score.musicParts.count, 1)
        
        print("first note: ", score.musicParts[0].measures[0].notes[0])
        XCTAssertEqual(score.musicParts[0].measures[0].notes[0].pitch, "A#4")
        XCTAssertEqual(score.musicParts[0].measures[0].notes.count, 1)
        
        print("first measure: ", score.musicParts[0].measures[1])
        XCTAssertEqual(score.musicParts[0].measures[1].notes.count, 64)
    }
    
    func testSpring1stCorrectness() {
        let score = ScoreSamples.spring1st
        
        XCTAssertEqual(score.musicParts.count, 2)
        
        let pianoPart = score.musicPartOf(instrument: .piano)!
        let violinPart = score.musicPartOf(instrument: .violin)!
        
        print("first measure of the violin part: ", violinPart.measures[0])
        print("first measure of piano part: ", pianoPart.measures[0])
        print("first note in violin part: ", violinPart.measures[0].notes[0])
        
        print(score)
    }
    
    func testScoreLoadFromURL() {
        let score = MusicScore(url: ScoreSamples.url_spring1st)!
        print(score)
    }

    /// test score description
    func testScoreDesc() {
        let score = ScoreSamples.chopin92
        print(score)
    }
}

//  BaseTypesTests.swift
//  MusicScore
//
//  Copyright © 2022 live77. All rights reserved.

import XCTest
import MusicScore

class BaseTypesTests: XCTestCase {
    
    func testMeasureSubscript() {
        let score = ScoreSamples.sonataPathetique
        let pianoPart = score.musicPartOf(instrument: .piano)!
        let measure0 = pianoPart.measures[0]
        
        XCTAssertEqual(measure0.beats, 2)
        
        print(measure0)
        
        XCTAssertEqual(measure0.notes(inBeat: 0).count, 6)
        XCTAssertEqual(measure0.notes(inBeat: 1).count, 6)
        XCTAssertEqual(measure0.notes(inBeat: 2).count, 0)
    }
}

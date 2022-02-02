//  BaseTypesTests.swift
//  MusicScore
//
//  Copyright © 2022 live77. All rights reserved.

import XCTest
import MusicScore

class BaseTypesTests: XCTestCase {
    
    func testMeasureSubscript() {
        let score = ScoreSamples.sonataPathetique
        let measure = score.musicPartOf(instrument: .piano)![0]
        
        XCTAssertEqual(measure.beats, 2)
        XCTAssertEqual(measure[0].count, 6)
        XCTAssertEqual(measure[1].count, 6)
        XCTAssertEqual(measure[2].count, 0)
    }
}

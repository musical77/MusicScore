

import Foundation

import XCTest
import MusicSymbol
import MusicScore

class ScoreManipluateTests: XCTestCase {

    func testScoreSubset() {
        let score = ScoreSamples.spring1st
        XCTAssertEqual(score.numberOfMeasures, 332)
        
        let subScore = score.subset(beginMeasureIdx: 0, endMeasureIdx: 1)
        XCTAssertEqual(subScore.numberOfMeasures, 1)
        XCTAssertEqual(score.numberOfMeasures, 332)
        print(subScore)
    }
}


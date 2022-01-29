//
////  ScoreResourceRepo.swift
////  MusicScore
////
////  Copyright © 2022 live77. All rights reserved.
//
//import XCTest
//import MusicTheory
//@testable import MusicScore
//
//class ScoreResourceRepoTests: XCTestCase {
//
//    override func setUp() {
//        self.continueAfterFailure = false
//    }
//    
//    /// 测试读取乐谱基本信息是否正确
//    func testScoreLoad_pathetique() {
//        let url = ScoreResourceRepo.pathetique
//        let score = MusicScore(url: url)!
//
//        XCTAssertEqual(score.musicParts.count, 1)
//        XCTAssertNotNil(score.musicPartOf(instrument: .piano))
//
//        XCTAssertEqual(score.tempos[0].timeSignature.beats, 2)
//        XCTAssertEqual(score.tempos[0].timeSignature.noteTimeValue, .quarter)
//        XCTAssertEqual(score.tempos[0].bpm, 26.66999745301524)
//        XCTAssertEqual(score.tempos[0].durationPerBeat, 2.2497190000000002)
//    }
//
//    /// 测试读取到的conduct信息,
//    func testScoreLoad_pathetique_c() {
//        let url = ScoreResourceRepo.pathetique_c
//        let score = MusicScore(url: url)!
//
//        XCTAssertEqual(score.musicParts.count, 1)
//        XCTAssertNotNil(score.musicPartOf(instrument: .piano))
//
//        XCTAssertEqual(score.tempos[0].timeSignature.beats, 2)
//        XCTAssertEqual(score.tempos[0].timeSignature.noteTimeValue, .quarter)
//        XCTAssertEqual(score.tempos[0].bpm, 27.00000270000027)
//        XCTAssertEqual(score.tempos[0].durationPerBeat, 2.222222)
//    }
//
//    /// 测试所有带conduct的乐谱,  每个音符应该在主谱中都存在
//    func testAllConductPoint() {
//        for desc in ScoreResourceRepo.scoreWithDescs {
//            print("check: ", desc.scoreName)
//
//            let conductScore = MusicScore(url: desc.scoreConductURL)!
//            let conductNotes = conductScore.musicPartOf(instrument: .piano)!.notes
//
//            let oriScore = MusicScore(url: desc.scoreURL)!
//            let oriNotes = oriScore.musicPartOf(instrument: .piano)!.notes
//
//            print("check: ", desc.scoreName, oriNotes.count, conductNotes.count)
//
//            var previousPosition = -1.0
//            var notMatchCount = 0
//            for note in conductNotes {
//                if note.beginBeat > previousPosition + 1e-6 {
//                    previousPosition = note.beginBeat
//                    let matchCount = oriNotes.filter { note_ori in
//                        return abs(note_ori.beginBeat - note.beginBeat) < 0.01 && note.pitch == note_ori.pitch
//                    }.count
//
//                    if matchCount == 0 {
//                        notMatchCount = notMatchCount + 1
//                    }
//                }
//            }
//
//            let notMatchRate = 1.0 * Double(notMatchCount) / Double(conductNotes.count)
//            print("check: ", conductNotes.count, notMatchCount, notMatchRate)
//
//            XCTAssertLessThan(notMatchRate, 0.05)
//        }
//    }
//
//    /// 测试读取bach c, 查看节拍数是否正确
//    func testBachReadDuration() {
//        let url = ScoreResourceRepo.bach_846
//        let score = MusicScore(url: url)!
//
//        let part = score.musicPartOf(instrument: .piano)!
//
//        print(part)
//
//        let url_c = ScoreResourceRepo.bach_846_c
//        let score_c = MusicScore(url: url_c)!
//        let part_c = score_c.musicPartOf(instrument: .piano)!
//
//        print(score.duration)
//        print(part.musicDuration)
//        print(score_c.duration)
//        print(part_c.musicDuration)
//    }
//}
//

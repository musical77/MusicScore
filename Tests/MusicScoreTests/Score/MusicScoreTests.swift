////  MusicScoreTests.swift
////  MusicScore
////
////  Copyright © 2022 live77. All rights reserved.
//
//import XCTest
//import MusicScore
//
//class MusicScoreTests: XCTestCase {
//    
//    /// 测试读取乐谱基本信息是否正确
//    func testScoreLoad1() {
//        let url = ScoreResourceRepo.sample
//        let score = MusicScore(url: url)!
//        
//        XCTAssertEqual(score.musicParts.count, 1)
//        
//        XCTAssertEqual(score.tempos[0].timeSignature.beats, 4)
//        XCTAssertEqual(score.tempos[0].timeSignature.noteTimeValue, .quarter)
//        XCTAssertEqual(score.tempos[0].bpm, 120)
//        XCTAssertEqual(score.tempos[0].durationPerBeat, 0.5)
//    }
//    
//    /// 测试读取乐谱的基本信息是否正确
//    func testScoreLoad2() {
//        let url = ScoreResourceRepo.spring1st
//        let score = MusicScore(url: url)!
//
//        /// 两个声部，小提琴和钢琴
//        XCTAssertEqual(score.musicParts.count, 2)
//        XCTAssertNotNil(score.musicPartOf(instrument: .piano))
//        XCTAssertNotNil(score.musicPartOf(instrument: .violin))
//
//        XCTAssertEqual(score.tempos[0].timeSignature.beats, 4)
//        XCTAssertEqual(score.tempos[0].timeSignature.noteTimeValue, .quarter)
//    }
//    
//    /// 测试读取乐谱的基本信息是否正确
//    func testScoreLoad3() {
//        let url = ScoreResourceRepo.chopin92
//        let score = MusicScore(url: url)!
//        
//        XCTAssertEqual(score.musicParts.count, 1)
//        XCTAssertNotNil(score.musicPartOf(instrument: .piano))
//        
//        XCTAssertEqual(score.tempos[0].timeSignature.beats, 1)
//        XCTAssertEqual(score.tempos[0].timeSignature.noteTimeValue, .eighth)
//        
//        XCTAssertEqual(score.tempos[1].timeSignature.beats, 12)
//        XCTAssertEqual(score.tempos[1].timeSignature.noteTimeValue, .eighth)
//        XCTAssertEqual(score.tempos[1].beginBeat, 0.5)
//        
//        // 节奏时间片段是依次不断开排列的
//        for idx in 0..<score.tempos.count - 1 {
//            XCTAssertEqual(score.tempos[idx].endBeat, score.tempos[idx + 1].beginBeat)
//        }
//    }
//    
//    func testScoreLoad4() {
//        let url = ScoreResourceRepo.Sonata_Pathetique
//        let score = MusicScore(url: url)!
//        
//        XCTAssertEqual(score.musicParts.count, 1)
//        XCTAssertNotNil(score.musicPartOf(instrument: .piano))
//        
//        let pianoPart = score.musicPartOf(instrument: .piano)!
//        XCTAssertEqual(73, pianoPart.measures.count)
//        
//        print(pianoPart.measures[0])
//    }
//
//    /// 测试读取的音符内容是否正确
//    func testReadNoteName1() {
//        let url = ScoreResourceRepo.sample
//        let score = MusicScore(url: url)!
//
//        // 6 1 2 3, first track is only A
//        XCTAssertEqual(score.musicParts[0].notes.count, 8)
//        XCTAssertEqual(score.musicParts[0].notes[0].noteName, "A3")
//        XCTAssertEqual(score.musicParts[0].notes[1].noteName, "C4")
//        XCTAssertEqual(score.musicParts[0].notes[2].noteName, "D4")
//        XCTAssertEqual(score.musicParts[0].notes[3].noteName, "E4")
//
//        XCTAssertEqual(score.musicParts[0].notes[0].phyDuration, 0.125)
//    }
//    
//    /// 测试读取的音符内容是否正确
//    func testReadNoteName2() {
//        let url = ScoreResourceRepo.spring1st
//        let score = MusicScore(url: url)!
//
//        // mi in F major, first note , A6
//        XCTAssertEqual(score.musicParts[0].notes.count, 1856)
//        XCTAssertEqual(score.musicParts[0].notes[0].noteName, "A5")
//        
//        print(score.musicParts[0].notes[0].description)
//
//        XCTAssertEqual(score.musicParts[0].notes[0].beats, 2)
//    }
//
//    /// 测试得到的小节信息是否正确
//    func testGetMeasures1() {
//        let url = ScoreResourceRepo.sample
//        let score = MusicScore(url: url)!
//
//        XCTAssertEqual(score.musicParts[0].measures.count, 1)
//        XCTAssertEqual(score.numberOfMeasures, 1)
//        
//        print(score.musicParts[0].measures[0])
//    }
//    
//    /// 测试得到的小节信息是否正确
//    func testGetMeasures2() {
//        let url = ScoreResourceRepo.spring1st
//        let score = MusicScore(url: url)!
//
//        XCTAssertEqual(score.musicParts[0].measures.count, 332)
//        XCTAssertEqual(score.musicParts[1].measures.count, 332)
//
//        XCTAssertEqual(score.numberOfMeasures, 332)
//    }
//    
//    func testGetMeasures3() {
//        let url = ScoreResourceRepo.chopin92
//        let score = MusicScore(url: url)!
//        
//        print(score.numberOfMeasures)
//        
//        print(score.musicPartOf(instrument: .piano)!.measures[0])
//        print(score.musicPartOf(instrument: .piano)!.measures[1])
//    }
//    
//    /// 测试得到的声部信息是否正确
//    func testMusicPartSubscript() {
//        let url = ScoreResourceRepo.Sonata_Pathetique
//        let score = MusicScore(url: url)!
//        
//        let part = score.musicPartOf(instrument: .piano)!
//        
//        XCTAssertEqual(part[0].beats, 2)
//        XCTAssertEqual(part[0][0].count, 6)
//        print(part[0])
//        print(part[1])
//    }
//    
//    /// 测试下标
//    func testMusicPartSubscript2() {
//        let url = ScoreResourceRepo.Sonata_Pathetique
//        let score = MusicScore(url: url)!
//        
//        let part = score.musicPartOf(instrument: .piano)!
//        
//        let notes = part[0.0, 1.0]
//        print(notes)
//    }
//
//    /// 测试description
//    func testGetDesc1() {
//        let url = ScoreResourceRepo.sample
//        let score = MusicScore(url: url)!
//
//        XCTAssertEqual(score.musicParts[0].description, """
//meta: 4tracks.mid_0, unknown
//----------------
//measure: 0, [0.0, 3.75), tempo: [0.000, inf) 🎼4/4 bpm:120
//[0.000-0.250) 🎵A3 1/16 beats:0.250 duration:0.125 ⬇️98 ⬆️64
//[0.500-0.750) 🎵C4 1/16 beats:0.250 duration:0.125 ⬇️98 ⬆️64
//[1.000-1.250) 🎵D4 1/16 beats:0.250 duration:0.125 ⬇️98 ⬆️64
//[1.500-1.750) 🎵E4 1/16 beats:0.250 duration:0.125 ⬇️98 ⬆️64
//[2.000-2.250) 🎵A3 1/16 beats:0.250 duration:0.125 ⬇️98 ⬆️64
//[2.500-2.750) 🎵C4 1/16 beats:0.250 duration:0.125 ⬇️98 ⬆️64
//[3.000-3.250) 🎵D4 1/16 beats:0.250 duration:0.125 ⬇️98 ⬆️64
//[3.500-3.750) 🎵E4 1/16 beats:0.250 duration:0.125 ⬇️98 ⬆️64
//
//""")
//    }
//    
//    /// 测试乐谱截断
//    func testScoreCut() {
//        let url = ScoreResourceRepo.bach_846
//        var score = MusicScore(url: url)!
//        print(score.duration)
//        
//        score.cut(beginBeat: 0, endBeat: 8)
//        print(score.musicPartOf(instrument: .piano)!.notes)
//        let newDuration = score.duration
//        
//        print(newDuration)
//        XCTAssertLessThan(newDuration, 8.01)
//    }
//
//}

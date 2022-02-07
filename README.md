# MusicScore

[![Swift](https://github.com/musical77/MusicScore/actions/workflows/swift.yml/badge.svg?branch=main)](https://github.com/musical77/MusicScore/actions/workflows/swift.yml)

A music score library with `MusicPart`, `Measure`, `Note`, `Pitch` and `Tempo` representations in swift structs.

Support read music score from MIDI file. 

Requirements
----
* Swift 5.0+
* iOS 14.0+
* macOS 13.0+


Install
----

### Swift Package Manager

``` swift
let package = Package(
  name: ...
  dependencies: [
    .package(url: "https://github.com/musical77/MusicScore.git")
  ],
  targets: ...
)
```


Usage
----

`MusicScore` supports load a score from mid file.

### Get a MusicScore from a MID file URL 

``` swift
let score = MusicScore(url: ScoreSamples.url_spring1st)!
print(score)
```

### Access MusicPart, Measures and Notes

``` swift 
let score = ScoreSamples.spring1st  // get a sample from embedded resource
        
let pianoPart = score.musicPartOf(instrument: .piano)!
let violinPart = score.musicPartOf(instrument: .violin)!
        
print("first measure of the violin part: ", violinPart.measures[0])
print("first measure of piano part: ", pianoPart.measures[0])
print("first note in violin part: ", violinPart.measures[0].notes[0])
```

### Console Output 

``` txt
first measure of the violin part:  measure: 0, [0.0, 4.0), tempo: [0.000, inf) 🎼4/4 bpm:120
[0.000-2.000) 🎵A5 1/2 beats:2.000 duration:1.000 ⬇️80 ⬆️0
[2.000-2.250) 🎵G5 1/16 beats:0.250 duration:0.125 ⬇️80 ⬆️0
[2.250-2.500) 🎵F5 1/16 beats:0.250 duration:0.125 ⬇️80 ⬆️0
[2.500-2.750) 🎵E5 1/16 beats:0.250 duration:0.125 ⬇️80 ⬆️0
[2.750-3.000) 🎵F5 1/16 beats:0.250 duration:0.125 ⬇️80 ⬆️0
[3.000-3.250) 🎵G5 1/16 beats:0.250 duration:0.125 ⬇️80 ⬆️0
[3.250-3.500) 🎵F5 1/16 beats:0.250 duration:0.125 ⬇️80 ⬆️0
[3.500-3.750) 🎵E5 1/16 beats:0.250 duration:0.125 ⬇️80 ⬆️0
[3.750-4.000) 🎵D5 1/16 beats:0.250 duration:0.125 ⬇️80 ⬆️0

first measure of piano part:  measure: 0, [0.0, 4.0), tempo: [0.000, inf) 🎼4/4 bpm:120
[0.000-0.500) 🎵A3 1/8 beats:0.500 duration:0.250 ⬇️80 ⬆️0
[0.000-4.000) 🎵F2 1 beats:4.000 duration:2.000 ⬇️80 ⬆️0
[0.500-1.000) 🎵C4 1/8 beats:0.500 duration:0.250 ⬇️80 ⬆️0
[1.000-1.500) 🎵F4 1/8 beats:0.500 duration:0.250 ⬇️80 ⬆️0
[1.500-2.000) 🎵C4 1/8 beats:0.500 duration:0.250 ⬇️80 ⬆️0
[2.000-2.500) 🎵A3 1/8 beats:0.500 duration:0.250 ⬇️80 ⬆️0
[2.500-3.000) 🎵C4 1/8 beats:0.500 duration:0.250 ⬇️80 ⬆️0
[3.000-3.500) 🎵F4 1/8 beats:0.500 duration:0.250 ⬇️80 ⬆️0
[3.500-4.000) 🎵C4 1/8 beats:0.500 duration:0.250 ⬇️80 ⬆️0

first note in violin part:  [0.000-2.000) 🎵A5 1/2 beats:2.000 duration:1.000 ⬇️80 ⬆️0
```

### ScoreSamples.spring1st

`ScoreSamples.spring1st` is a MusicScore of Beethoven Violin Sonata No.5 Op.24 Spring movement I Allegro.
Here shows the first 2 measures of this masterpiece.


<img width="644" alt="截屏2022-02-02 下午5 46 22" src="https://user-images.githubusercontent.com/51254187/152130287-c7873c82-c2e6-431a-b6ff-d13afb1d9fdc.png">


Reference
---

MIDI FILE Format

http://www.music.mcgill.ca/~ich/classes/mumt306/StandardMIDIfileformat.html

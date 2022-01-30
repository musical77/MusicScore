# MusicScore

[![Swift](https://github.com/musical77/MusicScore/actions/workflows/swift.yml/badge.svg?branch=main)](https://github.com/musical77/MusicScore/actions/workflows/swift.yml)

A music score library with `MusicPart`, `Measure`, `Note`, `Pitch` and `Tempo` representations in swift structs.
Support read music score from MID file. 

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

### Create a MusicScore from sample mid in prepared resouce bundle

``` swift
let score = MusicScore(url: ScoreSamples.sample)!  // 4tracks.mid
print(score)
```

### Create a MusicScore from given mid file url

``` swift
let url = URL(..) // mid file url
let score = MusicScore(url: url)
```

### Sample MIDI file (4tracks.mid)

![image](https://user-images.githubusercontent.com/51254187/151688910-43f66c44-678b-488e-afe0-8e58eec4af52.png)

### Sample Output 

``` txt
Score: 4tracks.mid
meta: 4tracks.mid_0, instrument: unknown
----------------
measure: 0, [0.0, 3.75), tempo: [0.000, inf) 🎼4/4 bpm:120
[0.000-0.250) 🎵A3 1/16 beats:0.250 duration:0.125 ⬇️98 ⬆️64
[0.500-0.750) 🎵C4 1/16 beats:0.250 duration:0.125 ⬇️98 ⬆️64
[1.000-1.250) 🎵D4 1/16 beats:0.250 duration:0.125 ⬇️98 ⬆️64
[1.500-1.750) 🎵E4 1/16 beats:0.250 duration:0.125 ⬇️98 ⬆️64
[2.000-2.250) 🎵A3 1/16 beats:0.250 duration:0.125 ⬇️98 ⬆️64
[2.500-2.750) 🎵C4 1/16 beats:0.250 duration:0.125 ⬇️98 ⬆️64
[3.000-3.250) 🎵D4 1/16 beats:0.250 duration:0.125 ⬇️98 ⬆️64
[3.500-3.750) 🎵E4 1/16 beats:0.250 duration:0.125 ⬇️98 ⬆️64
```

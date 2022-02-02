//
//  ScoreSamples.swift
//

import Foundation

public class ScoreSamples {

    /// scores
    ///
    static public var salutdAmour: MusicScore {
        return MusicScore(url: url_salutdAmour)!
    }
    
    static public var spring1st: MusicScore {
        return MusicScore(url: url_spring1st)!
    }
    
    static public var chopin92: MusicScore {
        return MusicScore(url: url_chopin92)!
    }
    
    static public var sonataPathetique: MusicScore {
        return MusicScore(url: url_sonataPathetique)!
    }
    
    /// url
    
    static public var url_salutdAmour: URL {
        return Bundle.module.url(
            forResource: "Salut_dAmour_Loves_Greeting_Op._12", withExtension:"mid")!
    }

    static public var url_spring1st: URL {
        return Bundle.module.url(forResource: "Beethoven_-_Violin_Sonata_No.5_Op.24_Spring_movement_I._Allegro",
                                 withExtension:"mid")!
    }

    static public var url_chopin92: URL {
        return Bundle.module.url(forResource: "Chopin_-_Nocturne_Op_9_No_2_E_Flat_Major", withExtension: "mid")!
    }

    static public var url_sonataPathetique: URL {
        return Bundle.module.url(forResource: "Sonata_Pathetique", withExtension: "mid")!
    }

}


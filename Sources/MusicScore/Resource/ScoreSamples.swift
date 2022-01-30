//
//  ScoreSamples.swift
//

import Foundation

public class ScoreSamples {

    static public var salutdAmour: URL {
        return Bundle.module.url(
            forResource: "Salut_dAmour_Loves_Greeting_Op._12", withExtension:"mid")!
    }

    static public var spring1st: URL {
        return Bundle.module.url(forResource: "Beethoven_-_Violin_Sonata_No.5_Op.24_Spring_movement_I._Allegro",
                                 withExtension:"mid")!
    }

    static public var sample: URL {
        return Bundle.module.url(forResource: "4tracks",
                                 withExtension:"mid")!
    }

    static public var chopin92: URL {
        return Bundle.module.url(forResource: "Chopin_-_Nocturne_Op_9_No_2_E_Flat_Major", withExtension: "mid")!
    }

    static public var Sonata_Pathetique: URL {
        return Bundle.module.url(forResource: "Sonata_Pathetique", withExtension: "mid")!
    }

}


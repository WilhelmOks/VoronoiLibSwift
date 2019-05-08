//
//  Random.swift
//  VoronoiLibSwiftExample
//
//  Created by Wilhelm Oks on 08.05.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

import Foundation

class Random {
    enum Mode {
        case randomlySeeded
        case explicitlySeeded
    }
    
    let mode: Mode
    
    init(mode: Mode) {
        self.mode = mode
    }
    
    static func setGlobalSeed(_ seed: Int) {
        srand48(seed)
    }
    
    func nextUnitDouble() -> Double {
        switch mode {
        case .randomlySeeded:
            return Double(arc4random()) / Double(UInt32.max)
        case .explicitlySeeded:
            return drand48()
        }
    }
}

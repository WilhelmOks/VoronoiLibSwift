//
//  FortuneEvent.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 19.04.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

class FortuneEvent : FortuneComparable {
    var x: Double { fatalError("must be overridden") }
    var y: Double { fatalError("must be overridden") }
    
    func compareTo(_ other: FortuneEvent) -> Int {
        let c = y.compareTo(other.y);
        return c == 0 ? x.compareTo(other.x) : c;
    }
}

protocol FortuneComparable {
    func compareTo(_ other: Self) -> Int
}

fileprivate extension Double {
    func compareTo(_ other: Double) -> Int {
        return self < other ? -1 : self > other ? 1 : 0
    }
}

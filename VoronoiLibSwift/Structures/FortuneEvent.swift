//
//  FortuneEvent.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 19.04.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

class FortuneEvent : FortuneComparable {
    var point: VPoint { fatalError("must be overridden") }
    
    func compareTo(_ other: FortuneEvent) -> Int {
        let c = point.y.compareTo(other.point.y);
        return c == 0 ? point.x.compareTo(other.point.x) : c;
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

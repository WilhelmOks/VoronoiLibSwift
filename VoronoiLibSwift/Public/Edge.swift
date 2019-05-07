//
//  Edge.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 28.04.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

public final class Edge {
    public let start: SIMD2<Double>
    public let end: SIMD2<Double>
    
    public init(start: SIMD2<Double>, end: SIMD2<Double>) {
        self.start = start
        self.end = end
    }
    
    //TODO: add left/right Site
}

extension Edge {
    convenience init(_ vEdge: VEdge) {
        let start = vEdge.start
        let end = vEdge.end ?? VPoint(x: 0, y: 0)
        self.init(start: .init(x: start.x, y: start.y), end: .init(x: end.x, y: end.y))
    }
}

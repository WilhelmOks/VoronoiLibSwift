//
//  Edge.swift
//  VoronoiLib
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
}

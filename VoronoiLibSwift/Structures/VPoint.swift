//
//  VPoint.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 19.04.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

//TODO: should be in public folder
//TODO: maybe change to struct or SIMD2<Double> and/or optimize with operators for all components at once
public final class VPoint {
    public let x: Double
    public let y: Double
    
    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

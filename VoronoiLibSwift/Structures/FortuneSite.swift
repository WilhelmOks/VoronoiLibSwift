//
//  FortuneSite.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 19.04.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

//TODO: should be in the public folder
public final class FortuneSite {
    public let point: SIMD2<Double>
    
    var neighbors: [FortuneSite] = []
    
    public init(_ point: SIMD2<Double>) {
        self.point = point
    }
}

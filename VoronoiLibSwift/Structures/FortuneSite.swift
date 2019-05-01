//
//  FortuneSite.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 19.04.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

//TODO: should be in the public folder
public final class FortuneSite {
    let x: Double
    let y: Double
    
    var cell: [VEdge] = []
    
    var neighbors: [FortuneSite] = []
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

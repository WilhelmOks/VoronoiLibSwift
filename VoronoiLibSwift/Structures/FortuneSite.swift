//
//  FortuneSite.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 04.05.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

class FortuneSite {
    public let point: VPoint
        
    var neighbors: [FortuneSite] = [] //TODO: try setting the edges between the neighbors when adding a neighbor to prevent a post computation step for the polygons
    
    var publicSite: Any?
    
    init(_ point: VPoint) {
        self.point = point
    }
}

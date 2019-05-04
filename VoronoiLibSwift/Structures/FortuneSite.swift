//
//  FortuneSite.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 04.05.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

class FortuneSite {
    public let point: VPoint
        
    var neighbors: [FortuneSite] = []
    
    var publicSite: Any?
    
    init(_ point: VPoint) {
        self.point = point
    }
}

//
//  FortuneSite.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 04.05.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

class FortuneSite {
    public let point: VPoint
        
    private(set) var neighbors: [FortuneSite] = []
    private(set) var cellEdges: [VEdge] = []
    
    /// This is actually `Site<UserData>`. `Any` is just eliminating the need to carry the generic type `UserData` in `FortuneSite`.
    var publicSite: Any?
    
    init(_ point: VPoint) {
        self.point = point
    }
    
    func addNeighbor(site: FortuneSite, edge: VEdge) {
        neighbors.append(site)
        cellEdges.append(edge)
    }
}

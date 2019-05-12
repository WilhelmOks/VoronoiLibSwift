//
//  FortuneSite.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 04.05.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

class FortuneSite {
    let point: VPoint
        
    private(set) var neighbors: [FortuneSite] = []
    private(set) var cellEdges: [VEdge] = []
    
    var borderPoints: Set<VPoint> = []
    
    /// This is actually `Site<UserData>`. `Any` is just eliminating the need to carry the generic type `UserData` in `FortuneSite`.
    var publicSite: Any?
    
    init(_ point: VPoint) {
        self.point = point
    }
    
    func addNeighbor(site: FortuneSite, edge: VEdge) {
        neighbors.append(site)
        cellEdges.append(edge)
    }
    
    func addBorderCellEdge(_ edge: VEdge) {
        cellEdges.append(edge)
    }
}

extension FortuneSite : Hashable {
    static func == (lhs: FortuneSite, rhs: FortuneSite) -> Bool {
        return lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(point.x)
        hasher.combine(point.y)
    }
}

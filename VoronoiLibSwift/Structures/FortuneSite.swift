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
    
    //var borderPoints: Set<VPoint> = []
    private(set) var pointsByBorders: [ClipAreaBorder: [VPoint]] = [.left: [], .right: [], .top: [], .bottom: []]
    
    var emptyBorders: Set<ClipAreaBorder> {
        return ClipAreaBorder.all.subtracting(addedBorders)
    }
    
    private(set) var addedBorders: Set<ClipAreaBorder> = []
    
    /// This is actually `Site<UserData>`. `Any` is just eliminating the need to carry the generic type `UserData` in `FortuneSite`.
    var publicSite: Any?
    
    init(_ point: VPoint) {
        self.point = point
    }
    
    func addNeighbor(site: FortuneSite, edge: VEdge) {
        neighbors.append(site)
        cellEdges.append(edge)
    }
    
    func addBorderCellEdge(_ edge: VEdge, border: ClipAreaBorder) {
        cellEdges.append(edge)
        addedBorders.insert(border)
    }
    
    func removeCellEdge(_ edge: VEdge) {
        cellEdges.removeAll { $0 === edge }
    }
    
    func add(point: VPoint, forBorder border: ClipAreaBorder) {
        pointsByBorders[border]?.append(point)
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

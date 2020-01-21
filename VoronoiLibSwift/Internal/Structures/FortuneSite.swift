//
//  FortuneSite.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 04.05.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

class FortuneSite {
    private(set) var point: VPoint
        
    private(set) var neighbors: [FortuneSite] = []
    private(set) var cellEdges: [VEdge] = []
    
    private(set) var pointsByBorders: [ClipRect.Border: [VPoint]] = [.left: [], .right: [], .top: [], .bottom: []]
    
    var emptyBorders: Set<ClipRect.Border> {
        return ClipRect.Border.all.subtracting(addedBorders)
    }
    
    private(set) var addedBorders: Set<ClipRect.Border> = []
    
    /// This is actually `Site<UserData>`. `Any` is just eliminating the need to carry the generic type `UserData` in `FortuneSite`.
    var publicSite: Any?
    
    init(_ point: VPoint) {
        self.point = point
    }
    
    func randomlyOffsetLocation(magnitude: Double) -> Self {
        if (magnitude != 0) {
            let randomOffsetRange = (-abs(magnitude)...abs(magnitude))
            point.x += .random(in: randomOffsetRange)
            point.y += .random(in: randomOffsetRange)
        }
        return self
    }
    
    func addNeighbor(site: FortuneSite, edge: VEdge) {
        neighbors.append(site)
        cellEdges.append(edge)
    }
    
    func addBorderCellEdge(_ edge: VEdge, border: ClipRect.Border) {
        cellEdges.append(edge)
        addedBorders.insert(border)
    }
    
    func removeCellEdge(_ edge: VEdge) {
        cellEdges.removeAll { $0 === edge }
    }
    
    func add(point: VPoint, forBorder border: ClipRect.Border) {
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

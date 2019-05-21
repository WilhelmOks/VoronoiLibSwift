//
//  PolygonCalculation.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 21.05.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

enum PolygonCalculation<UserData> {
    static func addPolygonVertices(to sites: [Site<UserData>]) {
        for site in sites {
            let edges = site.fortuneSite.cellEdges
            site.polygonVertices = orderedPolygonEdges(from: edges).map { $0.start }
        }
    }
    
    private static func orderedPolygonEdges(from edges: [VEdge]) -> [Edge<UserData>] {
        guard edges.count > 1 else { return edges.map { Edge($0) } }
        
        var orderedEdges: [Edge<UserData>] = [.init(edges.first!)]
        var unorderedEdges = Array(edges.dropFirst())
        
        while !unorderedEdges.isEmpty {
            let last = orderedEdges.last!
            let foundConnection = unorderedEdges.first { approxEqual($0.start, last.end) || approxEqual($0.end, last.end) }
            if let foundConnection = foundConnection {
                let swapEnds = !approxEqual(last.end, foundConnection.start)
                let edge = Edge<UserData>(foundConnection, swappingEnds: swapEnds)
                orderedEdges.append(edge)
                unorderedEdges.removeAll { $0 === foundConnection }
            } else {
                break
            }
        }
        
        return orderedEdges
    }
    
    private static func approxEqual(_ point1: VPoint?, _ point2: VPoint?) -> Bool {
        if let point1 = point1, let point2 = point2 {
            return Approx.approxEqual(point1.x, point2.x) && Approx.approxEqual(point1.y, point2.y)
        } else {
            return false
        }
    }
}

//
//  Voronoi.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 21.05.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

public enum Voronoi {
    public enum Option {
        case edgesAlsoOnClipAreaBorders //TODO: rename to makeEdgesOnClipRectBorders
        case calculateCellPolygons //TODO: rename to makeSitePolygonVertices
    }
    
    public static func runFortunesAlgorithm<UserData>(sitePoints: [SitePoint<UserData>], clipRect: ClipRect, options: Set<Option>) -> (edges: [Edge<UserData>], sites: [Site<UserData>]) {
        let borderInfo = BorderInfoAggregator()
        if options.contains(.edgesAlsoOnClipAreaBorders) || options.contains(.calculateCellPolygons) {
            borderInfo.enabled = true
        }
        
        let double4 = clipRect.double4
        
        let sites = Set(sitePoints).map { Site(point: $0.point, userData: $0.userData) } //the Set makes the points approximately unique
        
        let fortuneSites = sites.map { $0.fortuneSite }
        
        let edges = FortunesAlgorithm.run(sites: fortuneSites, borderInfo: borderInfo, on: double4).array
        
        let borderEdges: [VEdge]
        if options.contains(.edgesAlsoOnClipAreaBorders) || options.contains(.calculateCellPolygons) {
            borderEdges = ClipBorderEdgeCalculation.makeBorderEdges(from: borderInfo, on: double4, withSites: fortuneSites)
        } else {
            borderEdges = []
        }
        
        let resultEdges: [VEdge]
        if options.contains(.edgesAlsoOnClipAreaBorders) {
            resultEdges = edges + borderEdges
        } else {
            resultEdges = edges
        }
        
        if options.contains(.calculateCellPolygons) {
            PolygonCalculation.addPolygonVertices(to: sites)
        }
        
        return (edges: resultEdges.map { Edge($0) }, sites: sites)
    }
}

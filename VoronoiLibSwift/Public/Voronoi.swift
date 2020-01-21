//
//  Voronoi.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 21.05.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

public enum Voronoi {
    public enum Option {
        case makeEdgesOnClipRectBorders
        case makeSitePolygonVertices
    }
    
    public static func runFortunesAlgorithm<UserData>(sitePoints: [SitePoint<UserData>], clipRect: ClipRect, options: Set<Option>, randomlyOffsetSiteLocationsBy: Double? = nil) -> (edges: [Edge<UserData>], sites: [Site<UserData>]) {
        let borderInfo = BorderInfoAggregator()
        if options.contains(.makeEdgesOnClipRectBorders) || options.contains(.makeSitePolygonVertices) {
            borderInfo.enabled = true
        }
        
        let double4 = clipRect.double4
        
        let sites = Set(sitePoints).map { Site(point: $0.point, userData: $0.userData) } //the Set makes the points approximately unique
        
        let fortuneSites = sites.map { $0.fortuneSite.randomlyOffsetLocation(magnitude: randomlyOffsetSiteLocationsBy ?? 0) }
        
        let edges = FortunesAlgorithm.run(sites: fortuneSites, borderInfo: borderInfo, on: double4)
        
        let borderEdges: [VEdge]
        if options.contains(.makeEdgesOnClipRectBorders) || options.contains(.makeSitePolygonVertices) {
            borderEdges = ClipBorderEdgeCalculation.makeBorderEdges(from: borderInfo, on: double4, withSites: fortuneSites)
        } else {
            borderEdges = []
        }
        
        let resultEdges: [VEdge]
        if options.contains(.makeEdgesOnClipRectBorders) {
            resultEdges = edges + borderEdges
        } else {
            resultEdges = edges
        }
        
        if options.contains(.makeSitePolygonVertices) {
            PolygonCalculation.addPolygonVertices(to: sites)
        }
        
        return (edges: resultEdges.map { Edge($0) }, sites: sites)
    }
}

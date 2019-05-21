//
//  ClipBorderEdgeCalculation.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 21.05.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

import simd

enum ClipBorderEdgeCalculation {
    static func makeBorderEdges(from borderInfo: BorderInfoAggregator, on clipRect: ClipRect.Double4, withSites sites: [FortuneSite]) -> [VEdge] {
        var edges: [VEdge] = []
        
        if borderInfo.sites.isEmpty && !sites.isEmpty {
            func borderEdge(border: ClipRect.Border, site: FortuneSite) -> VEdge {
                let points = border.corners.map { $0.point(forClipRect: clipRect) }
                let edge = VEdge(start: points.first!, left: site, right: site)
                edge.end = points.last!
                return edge
            }
            
            func squaredDistanceToClipRect(_ site: FortuneSite) -> Double {
                return ClipRect.Corner.all.map{ simd_distance_squared($0.point(forClipRect: clipRect), site.point) }.min()!
            }
            
            let site = sites.min { squaredDistanceToClipRect($0) < squaredDistanceToClipRect($1) }!
            
            for border in ClipRect.Border.all {
                let edge = borderEdge(border: border, site: site)
                site.addBorderCellEdge(edge, border: border)
                edges.append(edge)
            }
            
            return edges
        }
        
        for site in borderInfo.sites {
            for (border, points) in site.pointsByBorders {
                if points.count == 2 {
                    let edge = VEdge(start: points.first!, left: site, right: site)
                    edge.end = points.last!
                    site.addBorderCellEdge(edge, border: border)
                    edges.append(edge)
                }
            }
            
            var reachableCornerPoints: [ClipRect.Corner: VPoint] = [:]
            
            var cornersToCheck: Set<ClipRect.Corner> = []
            for emptyBorder in site.emptyBorders {
                cornersToCheck.formUnion(emptyBorder.corners)
            }
            
            func safePoint(site: FortuneSite) -> VPoint {
                let point = site.point
                if !Approx.valueIsWithin(value: point.x, lowerBound: clipRect.minX, upperBound: clipRect.maxX) || !Approx.valueIsWithin(value: point.y, lowerBound: clipRect.minY, upperBound: clipRect.maxY) {
                    let edge = site.cellEdges.first!
                    let newPoint = edge.start + ((edge.end! - edge.start) * 0.5)
                    let offset = (point - newPoint) / 10000000000
                    return newPoint + offset
                } else {
                    return point
                }
            }
            
            for corner in cornersToCheck {
                let cornerPoint = corner.point(forClipRect: clipRect)
                let sitePoint = safePoint(site: site)
                let reachable = !anyEdgeIntersects(site.cellEdges, line: (sitePoint, cornerPoint))
                if reachable {
                    reachableCornerPoints[corner] = cornerPoint
                }
            }
            
            var handledCornerBorders: Set<ClipRect.Border> = []
            
            for (reachableCorner, reachablePoint) in reachableCornerPoints {
                for borderAtCorner in reachableCorner.borders {
                    if !handledCornerBorders.contains(borderAtCorner) {
                        if let middlePoint = site.pointsByBorders[borderAtCorner]!.first {
                            let edge = VEdge(start: middlePoint, left: site, right: site)
                            edge.end = reachablePoint
                            site.addBorderCellEdge(edge, border: borderAtCorner)
                            handledCornerBorders.insert(borderAtCorner)
                            edges.append(edge)
                        } else if let otherCornerPoint = reachableCornerPoints[borderAtCorner.oppositeCorner(of: reachableCorner)!] {
                            let edge = VEdge(start: otherCornerPoint, left: site, right: site)
                            edge.end = reachablePoint
                            site.addBorderCellEdge(edge, border: borderAtCorner)
                            handledCornerBorders.insert(borderAtCorner)
                            edges.append(edge)
                        }
                    }
                }
            }
        }
        
        return edges
    }
    
    private static func edgeIntersects(_ edge: VEdge, line: (VPoint, VPoint)) -> Bool {
        return LineSegmentIntersection.doIntersect(p: edge.start, p2: edge.end ?? .zero, q: line.0, q2: line.1)
    }
    
    private static func anyEdgeIntersects(_ edges: [VEdge], line: (VPoint, VPoint)) -> Bool {
        for edge in edges {
            if edgeIntersects(edge, line: line) {
                return true
            }
        }
        return false
    }
}

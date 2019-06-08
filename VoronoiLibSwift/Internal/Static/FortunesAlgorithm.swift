//
//  FortunesAlgorithm.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 20.04.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

import simd

final class FortunesAlgorithm {
    static func run(sites: [FortuneSite], borderInfo: BorderInfoAggregator, on clipRect: ClipRect.Double4) -> [VEdge] {
        
        let eventQueue = MinHeap<FortuneEvent>(capacity: 5 * sites.count)
        for s in sites {
            let _ = eventQueue.insert(FortuneSiteEvent(s))
        }
        
        //init tree
        let beachLine = BeachLine()
        var edges = [VEdge]()
        let deleted = HashSet<FortuneCircleEvent>()
        
        //init edge list
        while eventQueue.count != 0 {
            let fEvent = eventQueue.pop()
            if fEvent is FortuneSiteEvent {
                beachLine.addBeachSection(siteEvent: fEvent as! FortuneSiteEvent, eventQueue: eventQueue, deleted: deleted, edges: &edges)
            } else {
                if deleted.contains(fEvent as! FortuneCircleEvent) {
                    deleted.remove(fEvent as! FortuneCircleEvent)
                } else {
                    beachLine.removeBeachSection(circle: fEvent as! FortuneCircleEvent, eventQueue: eventQueue, deleted: deleted, edges: &edges)
                }
            }
        }
        
        var edgesToRemove: [VEdge] = []
        //clip edges
        for edge in edges {
            let valid: Bool = clipEdge(edge: edge, clipRect: clipRect)
            if valid {
                if borderInfo.enabled {
                    if let border = border(for: edge.start, on: clipRect) {
                        borderInfo.add(point: edge.start, forSite: edge.left, onBorder: border)
                        borderInfo.add(point: edge.start, forSite: edge.right, onBorder: border)
                    }
                    if let edgeEnd = edge.end, let border = border(for: edgeEnd, on: clipRect) {
                        borderInfo.add(point: edgeEnd, forSite: edge.left, onBorder: border)
                        borderInfo.add(point: edgeEnd, forSite: edge.right, onBorder: border)
                    }
                }
            } else {
                edgesToRemove.append(edge)
                edge.left.removeCellEdge(edge)
                edge.right.removeCellEdge(edge)
            }
        }
        
        let n = edges.count
        for i in 0..<n {
            let ii = n - 1 - i
            let edge = edges[ii]
            for r in 0..<edgesToRemove.count {
                let rr = edgesToRemove.count - 1 - r
                let edgeToRemove = edgesToRemove[rr]
                if edge === edgeToRemove {
                    edgesToRemove.remove(at: rr)
                    edges.remove(at: ii)
                    break
                }
            }
        }
                
        return edges
    }
    
    private static func border(for point: VPoint, on clipRect: ClipRect.Double4) -> ClipRect.Border? {
        if Approx.approxEqual(point.x, clipRect.minX) {
            return .left
        } else if Approx.approxEqual(point.x, clipRect.maxX) {
            return .right
        } else if Approx.approxEqual(point.y, clipRect.minY) {
            return .top
        } else if Approx.approxEqual(point.y, clipRect.maxY) {
            return .bottom
        } else {
            return nil
        }
    }
    
    //combination of personal ray clipping alg and cohen sutherland
    private static func clipEdge(edge: VEdge, clipRect: ClipRect.Double4) -> Bool {
        let (minX, minY, maxX, maxY) = clipRect
        
        var accept = false
    
        //if its a ray
        if edge.end == nil {
            accept = clipRay(edge: edge, clipRect: clipRect)
        } else {
            //Cohen–Sutherland
            var start = computeOutCode(x: edge.start.x, y: edge.start.y, clipRect: clipRect)
            var end = computeOutCode(x: edge.end!.x, y: edge.end!.y, clipRect: clipRect)
        
            while true {
                if (start | end) == 0 {
                    accept = true
                    break
                }
                if (start & end) != 0 {
                    break
                }
    
                var x: Double = -1
                var y: Double = -1
                let outcode = start != 0 ? start : end
    
                if (outcode & 0x8) != 0 { // top
                    x = edge.start.x + (edge.end!.x - edge.start.x)*(maxY - edge.start.y)/(edge.end!.y - edge.start.y)
                    y = maxY
                } else if (outcode & 0x4) != 0 { // bottom
                    x = edge.start.x + (edge.end!.x - edge.start.x)*(minY - edge.start.y)/(edge.end!.y - edge.start.y)
                    y = minY
                } else if (outcode & 0x2) != 0 { //right
                    y = edge.start.y + (edge.end!.y - edge.start.y)*(maxX - edge.start.x)/(edge.end!.x - edge.start.x)
                    x = maxX
                } else if ((outcode & 0x1) != 0) { //left
                    y = edge.start.y + (edge.end!.y - edge.start.y)*(minX - edge.start.x)/(edge.end!.x - edge.start.x)
                    x = minX
                }
                
                let borderPoint = VPoint(x: x, y: y)
                
                if outcode == start {
                    edge.start = borderPoint
                    start = computeOutCode(x: x, y: y, clipRect: clipRect)
                } else {
                    edge.end = borderPoint
                    end = computeOutCode(x: x, y: y, clipRect: clipRect)
                }
            }
        }
        //if we have a neighbor
        if let neighbor = edge.neighbor {
            //check it
            let valid = clipEdge(edge: neighbor, clipRect: clipRect)
            //both are valid
            if accept && valid {
                if let neighborEnd = neighbor.end {
                    edge.start = neighborEnd
                }
            }
            //this edge isn't valid, but the neighbor is
            //flip and set
            if !accept && valid {
                if let neighborEnd = neighbor.end {
                    edge.start = neighborEnd
                }
                edge.end = neighbor.start
                accept = true
            }
        }
        
        return accept
    }
    
    private static func computeOutCode(x: Double, y: Double, clipRect: ClipRect.Double4) -> Int {
        let (minX, minY, maxX, maxY) = clipRect
        
        var code: Int = 0
        if Approx.approxEqual(x, minX) || Approx.approxEqual(x, maxX) {
            
        } else if x < minX {
            code |= 0x1
        } else if x > maxX {
            code |= 0x2
        }
        
        if Approx.approxEqual(y, minY) || Approx.approxEqual(y, maxY) {
            
        } else if y < minY {
            code |= 0x4
        } else if y > maxY {
            code |= 0x8
        }
        return code
    }
    
    private static func clipRay(edge: VEdge, clipRect: ClipRect.Double4) -> Bool {
        let (minX, minY, maxX, maxY) = clipRect
        
        let start = edge.start
        //horizontal ray
        if Approx.approxZero(edge.slopeRise) {
            if !Approx.valueIsWithin(value: start.y, lowerBound: minY, upperBound: maxY) {
                return false
            }
            if edge.slopeRun > 0 && start.x > maxX {
                return false
            }
            if edge.slopeRun < 0 && start.x < minX {
                return false
            }
            if Approx.valueIsWithin(value: start.x, lowerBound: minX, upperBound: maxX) {
                let edgeEnd = edge.slopeRun > 0 ? VPoint(x: maxX, y: start.y) : VPoint(x: minX, y: start.y)
                edge.end = edgeEnd
            } else {
                let edgeStart = edge.slopeRun > 0 ? VPoint(x: minX, y: start.y) : VPoint(x: maxX, y: start.y)
                let edgeEnd = edge.slopeRun > 0 ? VPoint(x: maxX, y: start.y) : VPoint(x: minX, y: start.y)
                edge.start = edgeStart
                edge.end = edgeEnd
            }
            return true
        }
        //vertical ray
        if Approx.approxZero(edge.slopeRun) {
            if start.x < minX || start.x > maxX {
                return false
            }
            if edge.slopeRise > 0 && start.y > maxY {
                return false
            }
            if edge.slopeRise < 0 && start.y < minY {
                return false
            }
            if Approx.valueIsWithin(value: start.y, lowerBound: minY, upperBound: maxY) {
                let edgeEnd = edge.slopeRise > 0 ? VPoint(x: start.x, y: maxY) : VPoint(x: start.x, y: minY)
                edge.end = edgeEnd
            } else {
                let edgeStart = edge.slopeRise > 0 ? VPoint(x: start.x, y: minY) : VPoint(x: start.x, y: maxY)
                let edgeEnd = edge.slopeRise > 0 ? VPoint(x: start.x, y: maxY) : VPoint(x: start.x, y: minY)
                edge.start = edgeStart
                edge.end = edgeEnd
            }
            return true
        }
    
        //works for outside
        assert(edge.slope != nil, "edge.Slope != nil")
        assert(edge.intercept != nil, "edge.Intercept != nil")
        let topX = VPoint(x: calcX(m: edge.slope!, y: maxY, b: edge.intercept!), y: maxY)
        let bottomX = VPoint(x: calcX(m: edge.slope!, y: minY, b: edge.intercept!), y: minY)
        let leftY = VPoint(x: minX, y: calcY(m: edge.slope!, x: minX, b: edge.intercept!))
        let rightY = VPoint(x: maxX, y: calcY(m: edge.slope!, x: maxX, b: edge.intercept!))
    
        //reject intersections not within bounds
        var candidates = Array<VPoint>()
        if Approx.valueIsWithin(value: topX.x, lowerBound: minX, upperBound: maxX) {
            candidates.append(topX)
        }
        if Approx.valueIsWithin(value: bottomX.x, lowerBound: minX, upperBound: maxX) {
            candidates.append(bottomX)
        }
        if Approx.valueIsWithin(value: leftY.y, lowerBound: minY, upperBound: maxY) {
            candidates.append(leftY)
        }
        if Approx.valueIsWithin(value: rightY.y, lowerBound: minY, upperBound: maxY) {
            candidates.append(rightY)
        }
    
        //reject candidates which don't align with the slope
        var i = candidates.count - 1
        while i > -1 {
            let candidate = candidates[i]
            //grab vector representing the edge
            let ax = candidate.x - start.x
            let ay = candidate.y - start.y
            if edge.slopeRun*ax + edge.slopeRise*ay < 0 {
                candidates.remove(at: i)
            }
            i -= 1
        }
    
        //if there are two candidates we are outside the closer one is start
        //the further one is the end
        if candidates.count == 2 {
            let candidate0 = candidates[0]
            let candidate1 = candidates[1]
            let a = candidate0 - start
            let b = candidate1 - start
            let aGraterThanB = simd_length_squared(a) > simd_length_squared(b)
            let edgeStart = aGraterThanB ? candidate1 : candidate0
            let edgeEnd = aGraterThanB ? candidate0 : candidate1
            edge.start = edgeStart
            edge.end = edgeEnd
        }
    
        //if there is one candidate we are inside
        if candidates.count == 1 {
            let candidate = candidates[0]
            edge.end = candidate
        }
    
        //there were no candidates
        return edge.end != nil
    }
    
    private static func calcY(m: Double, x: Double, b: Double) -> Double {
        return m * x + b
    }
    
    private static func calcX(m: Double, y: Double, b: Double) -> Double {
        return (y - b) / m
    }
}

//
//  FortunesAlgorithm.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 20.04.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

public final class FortunesAlgorithm {
    private init() {}
    
    //TODO: make not static
    //TODO: make sites parameter a public Vector2 type
    public static func run(sites: [FortuneSite], minX: Double, minY: Double, maxX: Double, maxY: Double) -> [Edge] {
        
        let eventQueue = MinHeap<FortuneEvent>(capacity: 5 * sites.count)
        for s in sites {
            let _ = eventQueue.insert(FortuneSiteEvent(s))
        }
        
        //init tree
        let beachLine = BeachLine()
        let edges = LinkedList<VEdge>()
        let deleted = HashSet<FortuneCircleEvent>()
        
        //init edge list
        while eventQueue.count != 0 {
            let fEvent = eventQueue.pop()
            if fEvent is FortuneSiteEvent {
                beachLine.addBeachSection(siteEvent: fEvent as! FortuneSiteEvent, eventQueue: eventQueue, deleted: deleted, edges: edges)
            } else {
                if (deleted.contains(fEvent as! FortuneCircleEvent)) {
                    deleted.remove(fEvent as! FortuneCircleEvent)
                } else {
                    beachLine.removeBeachSection(circle: fEvent as! FortuneCircleEvent, eventQueue: eventQueue, deleted: deleted, edges: edges)
                }
            }
        }
        
        var edgesToRemove: [VEdge] = []
        //clip edges
        for edge in edges.array {
            let valid: Bool = clipEdge(edge: edge, minX: minX, minY: minY, maxX: maxX, maxY: maxY)
            if !valid {
                edgesToRemove.append(edge)
            }
        }
        edges.removeAll(edgesToRemove)
        
        return edges.array.map { edge in
            let start = edge.start
            let end = edge.end ?? VPoint(x: 0, y: 0)
            return Edge(start: .init(x: start.x, y: start.y), end: .init(x: end.x, y: end.y))
        }
    }
    
    //combination of personal ray clipping alg and cohen sutherland
    private static func clipEdge(edge: VEdge, minX: Double, minY: Double, maxX: Double, maxY: Double) -> Bool {
        var accept = false
    
        //if its a ray
        if edge.end == nil {
            accept = clipRay(edge: edge, minX: minX, minY: minY, maxX: maxX, maxY: maxY)
        } else {
            //Cohen–Sutherland
            var start = computeOutCode(x: edge.start.x, y: edge.start.y, minX: minX, minY: minY, maxX: maxX, maxY: maxY)
            var end = computeOutCode(x: edge.end!.x, y: edge.end!.y, minX: minX, minY: minY, maxX: maxX, maxY: maxY)
        
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
    
                if outcode == start {
                    edge.start = VPoint(x: x, y: y)
                    start = computeOutCode(x: x, y: y, minX: minX, minY: minY, maxX: maxX, maxY: maxY)
                } else {
                    edge.end = VPoint(x: x, y: y)
                    end = computeOutCode(x: x, y: y, minX: minX, minY: minY, maxX: maxX, maxY: maxY)
                }
            }
        }
        //if we have a neighbor
        if let neighbor = edge.neighbor {
            //check it
            let valid = clipEdge(edge: neighbor, minX: minX, minY: minY, maxX: maxX, maxY: maxY)
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
    
    private static func computeOutCode(x: Double, y: Double, minX: Double, minY: Double, maxX: Double, maxY: Double) -> Int {
        var code: Int = 0
        if ParabolaMath.approxEqual(x, minX) || ParabolaMath.approxEqual(x, maxX) {
            
        } else if x < minX {
            code |= 0x1
        } else if x > maxX {
            code |= 0x2
        }
        
        if ParabolaMath.approxEqual(y, minY) || ParabolaMath.approxEqual(y, maxY) {
            
        } else if y < minY {
            code |= 0x4
        } else if y > maxY {
            code |= 0x8
        }
        return code
    }
    
    private static func clipRay(edge: VEdge, minX: Double, minY: Double, maxX: Double, maxY: Double) -> Bool {
        let start = edge.start
        //horizontal ray
        if ParabolaMath.approxEqual(edge.slopeRise, 0) {
            if !within(x: start.y, a: minY, b: maxY) {
                return false
            }
            if edge.slopeRun > 0 && start.x > maxX {
                return false
            }
            if edge.slopeRun < 0 && start.x < minX {
                return false
            }
            if within(x: start.x, a: minX, b: maxX) {
                if edge.slopeRun > 0 {
                    edge.end = VPoint(x: maxX, y: start.y)
                } else {
                    edge.end = VPoint(x: minX, y: start.y)
                }
            } else {
                if edge.slopeRun > 0 {
                    edge.start = VPoint(x: minX, y: start.y)
                    edge.end = VPoint(x: maxX, y: start.y)
                } else {
                    edge.start = VPoint(x: maxX, y: start.y)
                    edge.end = VPoint(x: minX, y: start.y)
                }
            }
            return true
        }
        //vertical ray
        if ParabolaMath.approxEqual(edge.slopeRun, 0) {
            if start.x < minX || start.x > maxX {
                return false
            }
            if edge.slopeRise > 0 && start.y > maxY {
                return false
            }
            if edge.slopeRise < 0 && start.y < minY {
                return false
            }
            if within(x: start.y, a: minY, b: maxY) {
                if edge.slopeRise > 0 {
                    edge.end = VPoint(x: start.x, y: maxY)
                } else {
                    edge.end = VPoint(x: start.x, y: minY)
                }
            } else {
                if edge.slopeRise > 0 {
                    edge.start = VPoint(x: start.x, y: minY)
                    edge.end = VPoint(x: start.x, y: maxY)
                } else {
                    edge.start = VPoint(x: start.x, y: maxY)
                    edge.end = VPoint(x: start.x, y: minY)
                }
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
        if within(x: topX.x, a: minX, b: maxX) {
            candidates.append(topX)
        }
        if within(x: bottomX.x, a: minX, b: maxX) {
            candidates.append(bottomX)
        }
        if within(x: leftY.y, a: minY, b: maxY) {
            candidates.append(leftY)
        }
        if within(x: rightY.y, a: minY, b: maxY) {
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
            let ax = candidates[0].x - start.x
            let ay = candidates[0].y - start.y
            let bx = candidates[1].x - start.x
            let by = candidates[1].y - start.y
            if ax*ax + ay*ay > bx*bx + by*by {
                edge.start = candidates[1]
                edge.end = candidates[0]
            } else {
                edge.start = candidates[0]
                edge.end = candidates[1]
            }
        }
    
        //if there is one candidate we are inside
        if candidates.count == 1 {
            edge.end = candidates[0]
        }
    
        //there were no candidates
        return edge.end != nil
    }
    
    private static func within(x: Double, a: Double, b: Double) -> Bool {
        return ParabolaMath.approxGreaterThanOrEqualTo(x, a) && ParabolaMath.approxLessThanOrEqualTo(x, b)
    }
    
    private static func calcY(m: Double, x: Double, b: Double) -> Double {
        return m * x + b
    }
    
    private static func calcX(m: Double, y: Double, b: Double) -> Double {
        return (y - b) / m
    }
}

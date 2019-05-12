//
//  FortunesAlgorithm.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 20.04.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

import simd

//MARK: - public interface
public final class FortunesAlgorithm<UserData> {
    private init() {}
    
    public static func run(sites: [Site<UserData>], clipArea: Rect, options: Set<Option>) -> [Edge<UserData>] { //TODO: test what happens if two sites have qual points
        let borderInfo = ClipAreaBorderInfo()
        if options.contains(.edgesAlsoOnClipAreaBorders) || options.contains(.calculateCellPolygons) {
            borderInfo.enabled = true
        }
        
        let rect = clipArea.double4
        
        let edges = runMainAlgorithm(sites: sites, borderInfo: borderInfo, on: rect).array
        
        let borderEdges: [VEdge]
        if options.contains(.edgesAlsoOnClipAreaBorders) || options.contains(.calculateCellPolygons) {
            borderEdges = makeBorderEdges(from: borderInfo, on: rect)
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
            addPolygons(to: sites)
        }
        
        return resultEdges.map { Edge($0) }
    }
}

//MARK: - options
public extension FortunesAlgorithm {
    enum Rect { //TODO: move to somewhere else, so it is not inside of FortunesAlgorithm<UserData>
        case minMaxXY(minX: Double, minY: Double, maxX: Double, maxY: Double)
        case minMaxSimd(min: SIMD2<Double>, max: SIMD2<Double>)
        case rangeXY(x: ClosedRange<Double>, y: ClosedRange<Double>)
        case sizeXY(x: Double, y: Double)
        case sizeSimd(_ size: SIMD2<Double>)
        
        fileprivate var double4: (minX: Double, minY: Double, maxX: Double, maxY: Double) {
            switch self {
            case .minMaxXY(minX: let minX, minY: let minY, maxX: let maxX, maxY: let maxY):
                return (minX, minY, maxX, maxY)
            case .minMaxSimd(min: let min, max: let max):
                return (min.x, min.y, max.x, max.y)
            case .rangeXY(x: let x, y: let y):
                return (x.lowerBound, y.lowerBound, x.upperBound, y.upperBound)
            case .sizeXY(x: let x, y: let y):
                return (0, 0, x, y)
            case .sizeSimd(let size):
                return (0, 0, size.x, size.y)
            }
        }
    }
    
    enum Option { //TODO: move to somewhere else, so it is not inside of FortunesAlgorithm<UserData>
        case edgesAlsoOnClipAreaBorders
        case calculateCellPolygons
    }
}

fileprivate typealias Double4 = (minX: Double, minY: Double, maxX: Double, maxY: Double)

class ClipAreaBorderInfo {
    var sites: Set<FortuneSite> = []
    var enabled = false
    
    func add(point: VPoint, site: FortuneSite) {
        if enabled {
            sites.insert(site)
            site.borderPoints.insert(point)
        }
    }
}

enum ClipAreaBorder {
    case left
    case right
    case top
    case bottom
}

//MARK: - border edge calculation
private extension FortunesAlgorithm {
    static func makeBorderEdges(from borderInfo: ClipAreaBorderInfo, on clipRect: Double4) -> [VEdge] {
        var edges: [VEdge] = []
        for site in borderInfo.sites {
            var pointsForBorders: [ClipAreaBorder: [VPoint]] = [.left: [], .right: [], .top: [], .bottom: []]
            
            for point in site.borderPoints {
                if let border = border(for: point, on: clipRect) {
                    pointsForBorders[border]!.append(point)
                } else {
                    assertionFailure("Couldn't find a border for the point \(point)")
                }
            }
            for (_, points) in pointsForBorders {
                if points.count == 2 {
                    let edge = VEdge.init(start: points.first!, left: site, right: site)
                    edge.end = points.last!
                    site.addBorderCellEdge(edge)
                    edges.append(edge)
                }
            }
        }
        return edges
    }
    
    static func border(for point: VPoint, on clipRect: Double4) -> ClipAreaBorder? {
        switch (point.x, point.y) {
        case (clipRect.minX, _): return .left
        case (clipRect.maxX, _): return .right
        case (_, clipRect.minY): return .top
        case (_, clipRect.maxY): return .bottom
        default:                 return nil
        }
    }
}

//MARK: - polygon calculation
private extension FortunesAlgorithm {
    static func addPolygons(to sites: [Site<UserData>]) {
        for site in sites {
            /*var polygonEdges: [VEdge] = []
            for neighbor in site.fortuneSite.neighbors {
                if let edge = findEdge(in: edges, between: site.fortuneSite, and: neighbor) {
                    polygonEdges.append(edge)
                }
            }*/
            let polygonEdges = site.fortuneSite.cellEdges
            
            let orderedPolygonEdges = orderedForPolygon(polygonEdges)
            site.cellPolygonVertices = orderedPolygonEdges.map { $0.start }
        }
    }
    
    /*
    static func findEdge(in edges: [VEdge], between site1: FortuneSite, and site2: FortuneSite) -> VEdge? {
        return edges.first { $0.left === site1 && $0.right === site2 || $0.right === site1 && $0.left === site2 }
    }*/
    
    static func orderedForPolygon(_ edges: [VEdge]) -> [Edge<UserData>] {
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
    
    static func approxEqual(_ point1: VPoint?, _ point2: VPoint?) -> Bool {
        if let point1 = point1, let point2 = point2 {
            return ParabolaMath.approxEqual(point1.x, point2.x) && ParabolaMath.approxEqual(point1.y, point2.y)
        } else {
            return false
        }
    }
}

//MARK: - main algorithm
private extension FortunesAlgorithm {
    static func runMainAlgorithm(sites: [Site<UserData>], borderInfo: ClipAreaBorderInfo, on clipRect: Double4) -> LinkedList<VEdge> {
        
        let eventQueue = MinHeap<FortuneEvent>(capacity: 5 * sites.count)
        for s in sites {
            let _ = eventQueue.insert(FortuneSiteEvent(s.fortuneSite))
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
                if deleted.contains(fEvent as! FortuneCircleEvent) {
                    deleted.remove(fEvent as! FortuneCircleEvent)
                } else {
                    beachLine.removeBeachSection(circle: fEvent as! FortuneCircleEvent, eventQueue: eventQueue, deleted: deleted, edges: edges)
                }
            }
        }
        
        var edgesToRemove: [VEdge] = []
        //clip edges
        for edge in edges.array {
            let valid: Bool = clipEdge(edge: edge, borderInfo: borderInfo, clipRect: clipRect)
            if !valid {
                edgesToRemove.append(edge)
            }
        }
        edges.removeAll(edgesToRemove) //TODO: test if .filter is faster
        
        return edges
    }
    
    //combination of personal ray clipping alg and cohen sutherland
    static func clipEdge(edge: VEdge, borderInfo: ClipAreaBorderInfo, clipRect: Double4) -> Bool {
        let (minX, minY, maxX, maxY) = clipRect
        
        var accept = false
    
        //if its a ray
        if edge.end == nil {
            accept = clipRay(edge: edge, borderInfo: borderInfo, clipRect: clipRect)
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
                borderInfo.add(point: borderPoint, site: edge.left)
                borderInfo.add(point: borderPoint, site: edge.right)
                
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
            let valid = clipEdge(edge: neighbor, borderInfo: borderInfo, clipRect: clipRect)
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
    
    static func computeOutCode(x: Double, y: Double, clipRect: Double4) -> Int {
        let (minX, minY, maxX, maxY) = clipRect
        
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
    
    static func clipRay(edge: VEdge, borderInfo: ClipAreaBorderInfo, clipRect: Double4) -> Bool {
        let (minX, minY, maxX, maxY) = clipRect
        
        let start = edge.start
        //horizontal ray
        if ParabolaMath.approxZero(edge.slopeRise) {
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
                let edgeEnd = edge.slopeRun > 0 ? VPoint(x: maxX, y: start.y) : VPoint(x: minX, y: start.y)
                edge.end = edgeEnd
                borderInfo.add(point: edgeEnd, site: edge.left)
                borderInfo.add(point: edgeEnd, site: edge.right)
            } else {
                let edgeStart = edge.slopeRun > 0 ? VPoint(x: minX, y: start.y) : VPoint(x: maxX, y: start.y)
                let edgeEnd = edge.slopeRun > 0 ? VPoint(x: maxX, y: start.y) : VPoint(x: minX, y: start.y)
                edge.start = edgeStart
                edge.end = edgeEnd
                borderInfo.add(point: edgeStart, site: edge.left)
                borderInfo.add(point: edgeStart, site: edge.right)
                borderInfo.add(point: edgeEnd, site: edge.left)
                borderInfo.add(point: edgeEnd, site: edge.right)
            }
            return true
        }
        //vertical ray
        if ParabolaMath.approxZero(edge.slopeRun) {
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
                let edgeEnd = edge.slopeRise > 0 ? VPoint(x: start.x, y: maxY) : VPoint(x: start.x, y: minY)
                edge.end = edgeEnd
                borderInfo.add(point: edgeEnd, site: edge.left)
                borderInfo.add(point: edgeEnd, site: edge.right)
            } else {
                let edgeStart = edge.slopeRise > 0 ? VPoint(x: start.x, y: minY) : VPoint(x: start.x, y: maxY)
                let edgeEnd = edge.slopeRise > 0 ? VPoint(x: start.x, y: maxY) : VPoint(x: start.x, y: minY)
                edge.start = edgeStart
                edge.end = edgeEnd
                borderInfo.add(point: edgeStart, site: edge.left)
                borderInfo.add(point: edgeStart, site: edge.right)
                borderInfo.add(point: edgeEnd, site: edge.left)
                borderInfo.add(point: edgeEnd, site: edge.right)
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
            let candidate0 = candidates[0]
            let candidate1 = candidates[1]
            let a = candidate0 - start
            let b = candidate1 - start
            /*
            let ax = candidate0.x - start.x
            let ay = candidate0.y - start.y
            let bx = candidate1.x - start.x
            let by = candidate1.y - start.y
            if ax*ax + ay*ay > bx*bx + by*by {
                edge.start = candidate1
                edge.end = candidate0
            } else {
                edge.start = candidate0
                edge.end = candidate1
            }*/
            let aGraterThanB = simd_length_squared(a) > simd_length_squared(b)
            let edgeStart = aGraterThanB ? candidate1 : candidate0
            let edgeEnd = aGraterThanB ? candidate0 : candidate1
            edge.start = edgeStart
            edge.end = edgeEnd
            borderInfo.add(point: edgeStart, site: edge.left)
            borderInfo.add(point: edgeStart, site: edge.right)
            borderInfo.add(point: edgeEnd, site: edge.left)
            borderInfo.add(point: edgeEnd, site: edge.right)
        }
    
        //if there is one candidate we are inside
        if candidates.count == 1 {
            let candidate = candidates[0]
            edge.end = candidate
            borderInfo.add(point: candidate, site: edge.left)
            borderInfo.add(point: candidate, site: edge.right)
        }
    
        //there were no candidates
        return edge.end != nil
    }
    
    static func within(x: Double, a: Double, b: Double) -> Bool {
        return ParabolaMath.approxGreaterThanOrEqualTo(x, a) && ParabolaMath.approxLessThanOrEqualTo(x, b)
    }
    
    static func calcY(m: Double, x: Double, b: Double) -> Double {
        return m * x + b
    }
    
    static func calcX(m: Double, y: Double, b: Double) -> Double {
        return (y - b) / m
    }
}

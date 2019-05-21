//
//  Edge.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 28.04.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

public final class Edge<UserData> {
    public let start: SIMD2<Double>
    public let end: SIMD2<Double>
    
    public let siteA: Site<UserData>
    public let siteB: Site<UserData>?
    
    public var isOnClipRectBorder: Bool { return siteB == nil }
    
    private init(start: SIMD2<Double>, end: SIMD2<Double>, siteA: Site<UserData>, siteB: Site<UserData>?) {
        self.start = start
        self.end = end
        self.siteA = siteA
        self.siteB = siteB
    }
    
    internal convenience init(_ vEdge: VEdge, swappingEnds: Bool = false) {
        let vStart = vEdge.start
        let vEnd = vEdge.end ?? VPoint.zero
        
        let start = swappingEnds ? vEnd : vStart
        let end = swappingEnds ? vStart : vEnd
        
        let siteA = vEdge.left.publicSite as! Site<UserData>
        let siteB: Site<UserData>? = vEdge.right === vEdge.left ? nil : vEdge.right.publicSite as? Site<UserData>
        
        self.init(start: start, end: end, siteA: siteA, siteB: siteB)
    }
}

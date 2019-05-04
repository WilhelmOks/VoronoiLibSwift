//
//  VEdge.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 19.04.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

final class VEdge {
    var start: VPoint
    var end: VPoint?
    
    private(set) var left: FortuneSite
    private(set) var right: FortuneSite
    private(set) var slopeRise: Double
    private(set) var slopeRun: Double
    private(set) var slope: Double?
    private(set) var intercept: Double?
    
    var neighbor: VEdge?
    
    init(start: VPoint, left: FortuneSite, right: FortuneSite) {
        self.start = start
        self.left = left
        self.right = right
    
        //from negative reciprocal of slope of line from left to right
        //ala m = (left.y -right.y / left.x - right.x)
        slopeRise = left.point.x - right.point.x
        slopeRun = -(left.point.y - right.point.y)
    
        if ParabolaMath.approxEqual(slopeRise, 0) || ParabolaMath.approxEqual(slopeRun, 0) {
            slope = nil
            intercept = nil
        } else {
            let slope = slopeRise / slopeRun
            self.slope = slope
            intercept = start.y - slope * start.x
        }        
    }
}

extension VEdge : Equatable {
    public static func == (lhs: VEdge, rhs: VEdge) -> Bool {
        return lhs === rhs
    }
}

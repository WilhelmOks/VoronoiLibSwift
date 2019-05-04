//
//  ParabolaMath.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 19.04.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

import simd

struct ParabolaMath
{
    private static let epsilon = 4.94065645841247E-324 * 1E100
    
    static func evalParabola(focus: VPoint, directrix: Double, x: Double) -> Double {
        return 0.5 * ( (x - focus.x) * (x - focus.x) / (focus.y - directrix) + focus.y + directrix)
    }
    
    //gives the intersect point such that parabola 1 will be on top of parabola 2 slightly before the intersect
    static func intersectParabolaX(focus1: VPoint, focus2: VPoint, directrix: Double) -> Double {
        //admittedly this is pure voodoo.
        //there is attached documentation for this function
        return approxEqual(focus1.y, focus2.y)
        ? (focus1.x + focus2.x) * 0.5
        : (focus1.x * (directrix - focus2.y) + focus2.x * (focus1.y - directrix) +
        sqrt((directrix - focus1.y) * (directrix - focus2.y) *
        simd_length_squared(focus1 - focus2)
        )
        ) / (focus1.y - focus2.y)
    }
    
    static func approxZero(_ value: Double) -> Bool {
        return abs(value) <= epsilon
    }
    
    static func approxEqual(_ value1: Double, _ value2: Double) -> Bool {
        return abs(value1 - value2) <= epsilon
    }
    
    static func approxGreaterThanOrEqualTo(_ value1: Double, _ value2: Double) -> Bool {
        return value1 > value2 || approxEqual(value1, value2)
    }
    
    static func approxLessThanOrEqualTo(_ value1: Double, _ value2: Double) -> Bool {
        return value1 < value2 || approxEqual(value1, value2)
    }
}

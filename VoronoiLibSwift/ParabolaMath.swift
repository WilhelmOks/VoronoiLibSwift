//
//  ParabolaMath.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 19.04.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

struct ParabolaMath
{
    private static let epsilon = 4.94065645841247E-324 * 1E100
    
    static func evalParabola(focusX: Double, focusY: Double, directrix: Double, x: Double) -> Double {
        return 0.5 * ( (x - focusX) * (x - focusX) / (focusY - directrix) + focusY + directrix)
    }
    
    //gives the intersect point such that parabola 1 will be on top of parabola 2 slightly before the intersect
    static func intersectParabolaX(focus1X: Double, focus1Y: Double, focus2X: Double, focus2Y: Double, directrix: Double) -> Double {
        //admittedly this is pure voodoo.
        //there is attached documentation for this function
        return approxEqual(focus1Y, focus2Y)
        ? (focus1X + focus2X) * 0.5
        : (focus1X * (directrix - focus2Y) + focus2X * (focus1Y - directrix) +
        sqrt((directrix - focus1Y) * (directrix - focus2Y) *
        ((focus1X - focus2X) * (focus1X - focus2X) +
        (focus1Y - focus2Y) * (focus1Y - focus2Y))
        )
        ) / (focus1Y - focus2Y)
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

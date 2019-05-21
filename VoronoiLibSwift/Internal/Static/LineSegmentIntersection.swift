//
//  LineSegmentIntersection.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 18.05.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

enum LineSegmentIntersection<T : SIMDScalar & FloatingPoint> {
    typealias Point = SIMD2<T>
    
    static func doIntersect(p: Point, p2: Point, q: Point, q2: Point) -> Bool {
        let r = p2 - p
        let s = q2 - q
        
        let uNumerator = crossProduct(q - p, r)
        let denominator = crossProduct(r, s)
        
        if uNumerator == 0 && denominator == 0 {
            return !allEqual(q.x - p.x < 0, q.x - p2.x < 0, q2.x - p.x < 0, q2.x - p2.x < 0) ||
                !allEqual(q.y - p.y < 0, q.y - p2.y < 0, q2.y - p.y < 0, q2.y - p2.y < 0)
        }
        
        if denominator == 0 {
            return false
        }
        
        let u = uNumerator / denominator
        let t = crossProduct(q - p, s) / denominator
        
        return t >= 0 && t <= 1 && u >= 0 && u <= 1
    }
    
    private static func crossProduct(_ point1: Point, _ point2: Point) -> T {
        return point1.x * point2.y - point1.y * point2.x
    }
    
    private static func allEqual(_ a: Bool, _ b: Bool, _ c: Bool, _ d: Bool) -> Bool {
        return a == b && b == c && c == d
    }
}

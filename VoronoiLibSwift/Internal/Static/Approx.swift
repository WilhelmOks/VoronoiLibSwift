//
//  Approx.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 19.04.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

enum Approx {
    private static let epsilon = 4.94065645841247E-224
    
    @inlinable static func approxZero(_ value: Double) -> Bool {
        return abs(value) <= epsilon
    }
    
    @inlinable static func approxEqual(_ value1: Double, _ value2: Double) -> Bool {
        return abs(value1 - value2) <= epsilon
    }
    
    @inlinable static func approxGreaterThanOrEqualTo(_ value1: Double, _ value2: Double) -> Bool {
        return value1 > value2 || approxEqual(value1, value2)
    }
    
    @inlinable static func approxLessThanOrEqualTo(_ value1: Double, _ value2: Double) -> Bool {
        return value1 < value2 || approxEqual(value1, value2)
    }
    
    @inlinable static func valueIsWithin(value: Double, lowerBound: Double, upperBound: Double) -> Bool {
        return Approx.approxGreaterThanOrEqualTo(value, lowerBound) && Approx.approxLessThanOrEqualTo(value, upperBound)
    }
}

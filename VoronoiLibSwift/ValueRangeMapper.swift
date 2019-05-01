//
//  ValueRangeMapper.swift
//  VoronoiLib
//
//  Created by Wilhelm Oks on 28.04.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

final class ValueRangeMapper {
    private let range: ClosedRange<Double>
    
    init(range: ClosedRange<Double>) {
        self.range = range
    }
    
    func toRange(_ normalizedValue: Double) -> Double {
        return range.lowerBound + (range.upperBound - range.lowerBound) * normalizedValue
    }
    
    func toNormalized(_ valueInRange: Double) -> Double {
        return (valueInRange - range.lowerBound) / (range.upperBound - range.lowerBound)
    }
}

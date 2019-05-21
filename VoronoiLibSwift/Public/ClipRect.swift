//
//  ClipRect.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 21.05.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

public enum ClipRect {
    case minMaxXY(minX: Double, minY: Double, maxX: Double, maxY: Double)
    case minMaxSimd(min: SIMD2<Double>, max: SIMD2<Double>)
    case rangeXY(x: ClosedRange<Double>, y: ClosedRange<Double>)
    case sizeXY(x: Double, y: Double)
    case sizeSimd(_ size: SIMD2<Double>)
}

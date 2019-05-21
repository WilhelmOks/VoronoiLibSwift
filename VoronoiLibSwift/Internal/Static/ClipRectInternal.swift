//
//  ClipRectInternal.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 21.05.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

internal extension ClipRect {
    typealias Double4 = (minX: Double, minY: Double, maxX: Double, maxY: Double)
    
    var double4: Double4 {
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
    
    enum Border {
        case left
        case right
        case top
        case bottom
        
        static let all: Set<Border> = [.left, .right, .top, .bottom]
        
        var neighbors: [Border] {
            switch self {
            case .left, .right: return [.top, .bottom]
            case .top, .bottom: return [.left, .right]
            }
        }
        
        var corners: Set<Corner> {
            switch self {
            case .left: return [.topLeft, .bottomLeft]
            case .right: return [.topRight, .bottomRight]
            case .top: return [.topLeft, .topRight]
            case .bottom: return [.bottomLeft, .bottomRight]
            }
        }
        
        func oppositeCorner(of corner: Corner) -> Corner? {
            let corners = self.corners
            guard corners.contains(corner) else { return nil }
            return self.corners.subtracting([corner]).first
        }
    }
    
    enum Corner {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
        
        static let all: Set<Corner> = [.topLeft, .topRight, .bottomLeft, .bottomRight]
        
        init?(borderA: Border, borderB: Border) {
            let borders: Set<Border> = [borderA, borderB]
            switch borders {
            case [.left,  .top]:    self = .topLeft
            case [.right, .top]:    self = .topRight
            case [.left,  .bottom]: self = .bottomLeft
            case [.right, .bottom]: self = .bottomRight
            default: return nil
            }
        }
        
        func point(forClipRect clipRect: Double4) -> VPoint {
            switch self {
            case .topLeft:     return .init(x: clipRect.minX, y: clipRect.minY)
            case .topRight:    return .init(x: clipRect.maxX, y: clipRect.minY)
            case .bottomLeft:  return .init(x: clipRect.minX, y: clipRect.maxY)
            case .bottomRight: return .init(x: clipRect.maxX, y: clipRect.maxY)
            }
        }
        
        var borders: [Border] {
            switch self {
            case .topLeft: return [.top, .left]
            case .topRight: return [.top, .right]
            case .bottomLeft: return [.bottom, .left]
            case .bottomRight: return [.bottom, .right]
            }
        }
    }
}

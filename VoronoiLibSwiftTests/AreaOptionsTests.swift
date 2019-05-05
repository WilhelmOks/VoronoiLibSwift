//
//  VoronoiLibSwiftTests.swift
//  VoronoiLibSwiftTests
//
//  Created by Wilhelm Oks on 19.04.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

import XCTest
@testable import VoronoiLib

class AreaOptionsTests: XCTestCase {
    let accuracy: Double = 0.0001
    
    let points: [SIMD2<Double>] = [
        .init(0.1, 0.2),
        .init(0.3, 0.8),
        .init(0.9, 0.22),
        .init(0.79, 0.83),
    ]
    
    var sites: [Site<Void>] {
        return points.map { Site(point: $0) }
    }

    func testMinMaxXY() {        
        let edgesLimits = limitsForEdges(withArea: .minMaxXY(minX: -1, minY: -2, maxX: 1, maxY: 2))

        XCTAssertEqual(edgesLimits.minX, -1, accuracy: accuracy)
        XCTAssertEqual(edgesLimits.minY, -2, accuracy: accuracy)
        XCTAssertEqual(edgesLimits.maxX, 1, accuracy: accuracy)
        XCTAssertEqual(edgesLimits.maxY, 2, accuracy: accuracy)
    }
    
    func testMinMaxSimd() {
        let edgesLimits = limitsForEdges(withArea: .minMaxSimd(min: .init(x: -1, y: -2), max: .init(x: 1, y: 2)))

        XCTAssertEqual(edgesLimits.minX, -1, accuracy: accuracy)
        XCTAssertEqual(edgesLimits.minY, -2, accuracy: accuracy)
        XCTAssertEqual(edgesLimits.maxX, 1, accuracy: accuracy)
        XCTAssertEqual(edgesLimits.maxY, 2, accuracy: accuracy)
    }
    
    func testRangeXY() {
        let edgesLimits = limitsForEdges(withArea: .rangeXY(x: -1...1, y: -2...2))

        XCTAssertEqual(edgesLimits.minX, -1, accuracy: accuracy)
        XCTAssertEqual(edgesLimits.minY, -2, accuracy: accuracy)
        XCTAssertEqual(edgesLimits.maxX, 1, accuracy: accuracy)
        XCTAssertEqual(edgesLimits.maxY, 2, accuracy: accuracy)
    }
    
    func testSizeXY() {
        let edgesLimits = limitsForEdges(withArea: .sizeXY(x: 1, y: 2))
        
        XCTAssertEqual(edgesLimits.minX, 0, accuracy: accuracy)
        XCTAssertEqual(edgesLimits.minY, 0, accuracy: accuracy)
        XCTAssertEqual(edgesLimits.maxX, 1, accuracy: accuracy)
        XCTAssertEqual(edgesLimits.maxY, 2, accuracy: accuracy)
    }
    
    func testSizeSimd() {
        let edgesLimits = limitsForEdges(withArea: .sizeSimd(.init(x: 1, y: 2)))
        
        XCTAssertEqual(edgesLimits.minX, 0, accuracy: accuracy)
        XCTAssertEqual(edgesLimits.minY, 0, accuracy: accuracy)
        XCTAssertEqual(edgesLimits.maxX, 1, accuracy: accuracy)
        XCTAssertEqual(edgesLimits.maxY, 2, accuracy: accuracy)
    }
    
    private func limitsForEdges(withArea area: FortunesAlgorithm<Void>.Rect) -> (minX: Double, minY: Double, maxX: Double, maxY: Double) {
        let edges = FortunesAlgorithm.run(sites: sites, area: area, options: [])
        return limits(forEdges: edges)
    }
    
    private func limits(forEdges edges: [Edge]) -> (minX: Double, minY: Double, maxX: Double, maxY: Double) {
        var minX: Double = .infinity
        var minY: Double = .infinity
        var maxX: Double = -.infinity
        var maxY: Double = -.infinity
        
        func processMin(value: Double, current: inout Double) {
            if value < current {
                current = value
            }
        }
        
        func processMax(value: Double, current: inout Double) {
            if value > current {
                current = value
            }
        }
        
        for edge in edges {
            processMin(value: edge.start.x, current: &minX)
            processMin(value: edge.end.x, current: &minX)
            processMin(value: edge.start.y, current: &minY)
            processMin(value: edge.end.y, current: &minY)
            
            processMax(value: edge.start.x, current: &maxX)
            processMax(value: edge.end.x, current: &maxX)
            processMax(value: edge.start.y, current: &maxY)
            processMax(value: edge.end.y, current: &maxY)
        }
        
        return (minX, minY, maxX, maxY)
    }
}

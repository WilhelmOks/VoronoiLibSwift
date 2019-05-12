//
//  RenderView.swift
//  VoronoiLibSwiftExample
//
//  Created by Wilhelm Oks on 21.04.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

import Foundation
import UIKit
import VoronoiLib

class RenderView : UIView {
    var sites: [Site<UIColor>] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var edges: [(start: CGPoint, end: CGPoint)] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var edgeColor: UIColor = .orange {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard !edges.isEmpty else { return }
        
        /*for site in sites {
            let path = UIBezierPath()
            
            path.addArc(withCenter: site.point.cgPoint, radius: 1.5, startAngle: 0, endAngle: CGFloat.pi*2, clockwise: false)
            
            site.userData?.setFill()
            
            path.fill()
        }*/
        
        for site in sites {
            let path = UIBezierPath()
            
            guard site.cellPolygonVertices.count > 2 else { continue }
            
            path.move(to: site.cellPolygonVertices.first!.cgPoint)
            
            for point in site.cellPolygonVertices.dropFirst() {
                path.addLine(to: point.cgPoint)
            }
            
            site.userData?.setFill()
            
            path.fill()
        }
        
        edgeColor.set()
        
        for edge in edges {
            let path = UIBezierPath()
            
            path.move(to: edge.start)
            path.addLine(to: edge.end)
            
            path.lineWidth = 2
            path.stroke()
        }
    }
}

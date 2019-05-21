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
    var sites: [Site<UIColor>] = []
    var edges: [(start: CGPoint, end: CGPoint)] = []
    
    var edgeColor: UIColor = .orange {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        //filled site polygons:
        for site in sites {
            let path = UIBezierPath()
            
            let polygonVerties = site.polygonVertices
            
            guard polygonVerties.count > 2 else { continue }
            
            path.move(to: polygonVerties.first!.cgPoint)
            
            for point in polygonVerties.dropFirst() {
                path.addLine(to: point.cgPoint)
            }
            
            site.userData?.setFill()
            
            path.fill()
        }
        
        //edges:
        edgeColor.set()
        for edge in edges {
            let path = UIBezierPath()
            
            path.move(to: edge.start)
            path.addLine(to: edge.end)
            
            path.lineWidth = 2
            path.stroke()
        }
        
        //site location circles:
        UIColor.green.set()
        for site in sites {
            let path = UIBezierPath()
            
            path.addArc(withCenter: site.point.cgPoint, radius: 1.5, startAngle: 0, endAngle: CGFloat.pi*2, clockwise: false)
            
            //edgeColor.set()
            
            path.fill()
        }
    }
}

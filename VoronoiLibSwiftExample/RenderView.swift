//
//  RenderView.swift
//  VoronoiLibSwiftExample
//
//  Created by Wilhelm Oks on 21.04.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

import Foundation
import UIKit
import VoronoiLib //TODO: delete

class RenderView : UIView {
    var sites: [FortuneSite] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var siteColor: UIColor = .red {
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
        
        siteColor.setFill()
        
        for site in sites {
            let path = UIBezierPath()
            
            path.addArc(withCenter: CGPoint(x: site.x, y: site.y), radius: 1.5, startAngle: 0, endAngle: CGFloat.pi*2, clockwise: false)
            
            path.fill()
        }
        
        edgeColor.set()
        
        for edge in edges {
            let path = UIBezierPath()
            
            path.move(to: edge.start)
            path.addLine(to: edge.end)
            
            path.stroke()
        }
    }
}

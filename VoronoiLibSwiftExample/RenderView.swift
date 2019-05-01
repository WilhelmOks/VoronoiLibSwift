//
//  RenderView.swift
//  VoronoiLibSwiftExample
//
//  Created by Wilhelm Oks on 21.04.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

import Foundation
import UIKit

class RenderView : UIView {
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
        
        for edge in edges {
            let path = UIBezierPath()
            
            var start = edge.start
            var end = edge.end
            
            let scale: CGPoint = .init(x: 1, y: 1)
            
            start.x *= scale.x
            start.y *= scale.y
            
            end.x *= scale.x
            end.y *= scale.y
            
            path.move(to: start)
            path.addLine(to: end)
            
            //path.close()
            
            edgeColor.set()
            path.stroke()
            //path.fill()
            
        }
    }
}

//
//  ViewController.swift
//  VoronoiLibSwiftExample
//
//  Created by Wilhelm Oks on 21.04.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

import UIKit
import VoronoiLib

class ViewController: UIViewController {
    
    var renderView: RenderView {
        return view as! RenderView
    }
    
    var renderAreaSize: CGSize {
        let size = renderView.frame.size
        return size
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeNewVoronoi(ofSize: renderAreaSize)
        
        //endlessRepeat()
    }
    
    private func endlessRepeat() {
        DispatchQueue.main.asyncAfter(deadline: .now()
            + 0.1) {
            self.makeNewVoronoi(ofSize: self.renderAreaSize)
            self.endlessRepeat()
        }
    }
    
    override func viewDidLayoutSubviews() {
        makeNewVoronoi(ofSize: renderAreaSize)
    }
    
    @IBAction func didTapRefreshButton(_ sender: Any) {
        makeNewVoronoi(ofSize: renderAreaSize)
    }
    
    private func makeNewVoronoi(ofSize size: CGSize) {
        let numberOfSites = 200
        var sites: [FortuneSite] = []
        
        for _ in 0..<numberOfSites {
            var point = randomPointInArea(withSize: size)
            sites.append(FortuneSite(x: point.x, y: point.y))
        }
        
        let edges = FortunesAlgorithm.run(sites: sites, minX: 0, minY: 0, maxX: Double(size.width), maxY: Double(size.height))
        
        renderView.edges = edges.map { (start: $0.start.cgpoint, end: $0.end.cgpoint) }
    }
    
    private func randomPointInArea(withSize size: CGSize) -> SIMD2<Double> {
        let randomPoint = (
            x: Double(arc4random()) / Double(UInt32.max) * Double(size.width),
            y: Double(arc4random()) / Double(UInt32.max) * Double(size.height))
        return SIMD2(
            x: randomPoint.x,
            y: randomPoint.y)
    }
}

extension VPoint {
    var cgpoint: CGPoint {
        return CGPoint(x: x, y: y)
    }
}

extension SIMD2 where Scalar == Double {
    var cgpoint: CGPoint {
        return CGPoint(x: x, y: y)
    }
}

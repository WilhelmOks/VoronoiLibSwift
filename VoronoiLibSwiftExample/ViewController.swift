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
    let fortunesAlgorithmStopWatch = StopWatch(name: "FortunesAlgorithm")
    
    let randomForPoints = Random(mode: .randomlySeeded)
    let randomForColors = Random(mode: .randomlySeeded)
    
    let pointsSeed = 5
    
    var sitePoints: [SitePoint<UIColor>] = []
    
    var renderView: RenderView {
        return view as! RenderView
    }
    
    var renderAreaSize: CGSize {
        let size = renderView.frame.size
        return size
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hue: 0.35, saturation: 0.05, brightness: 0.99, alpha: 1)
        
        Random.setGlobalSeed(pointsSeed)
        
        makeSites(forViewSize: renderAreaSize)
        makeNewVoronoi(ofSize: renderAreaSize)
        
        renderView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapRenderArea)))
        renderView.isUserInteractionEnabled = true

        //endlessRepeat()
    }
    
    private func endlessRepeat() {
        DispatchQueue.main.asyncAfter(deadline: .now()
            + 0.1) {
            self.makeSites(forViewSize: self.renderAreaSize)
            self.makeNewVoronoi(ofSize: self.renderAreaSize)
            self.endlessRepeat()
        }
    }
    
    override func viewDidLayoutSubviews() {
        makeSites(forViewSize: renderAreaSize)
        makeNewVoronoi(ofSize: renderAreaSize)
    }
    
    @IBAction func didTapRefreshButton(_ sender: Any) {
        makeSites(forViewSize: renderAreaSize)
        makeNewVoronoi(ofSize: renderAreaSize)
    }
    
    @objc private func didTapRenderArea(_ gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(ofTouch: 0, in: renderView)
        
        print("tap location: \(location)")
        
        let site = SitePoint(point: SIMD2<Double>(x: Double(location.x), y: Double(location.y)), userData: randomColor())
        sitePoints.append(site)
        makeNewVoronoi(ofSize: renderAreaSize)
    }
    
    private func makeSites(forViewSize size: CGSize) {
        let numberOfSites = 10
        
        Random.setGlobalSeed(pointsSeed)
        
        sitePoints = []
        
        for _ in 0..<numberOfSites {
            let point = randomPointInArea(withSize: size)
            let color = randomColor()
            //let color = UIColor.red
            sitePoints.append(SitePoint(point: point, userData: color))
        }
    }
    
    private func makeNewVoronoi(ofSize size: CGSize) {
        fortunesAlgorithmStopWatch.run({ () -> (edges: [Edge<UIColor>], sites: [Site<UIColor>]) in
            let width = Double(size.width)
            let height = Double(size.height)
            let padding = 10.0
            let result = Voronoi.runFortunesAlgorithm(sitePoints: sitePoints, clipRect: .minMaxXY(minX: padding, minY: padding, maxX: width - padding, maxY: height - padding), options: [.calculateCellPolygons, .makeEdgesOnClipRectBorders])
            return result
        }) { (result, runTime) in
            fortunesAlgorithmStopWatch.printRunTime(runTime)
            fortunesAlgorithmStopWatch.printAverageRunTime()
            renderView.edges = result.edges.map { (start: $0.start.cgPoint, end: $0.end.cgPoint) }
            renderView.sites = result.sites
            renderView.setNeedsDisplay()
        }
    }
    
    private func randomPointInArea(withSize size: CGSize) -> SIMD2<Double> {
        let randomPoint = (
            x: randomForPoints.nextUnitDouble() * Double(size.width),
            y: randomForPoints.nextUnitDouble() * Double(size.height))
        return SIMD2(
            x: randomPoint.x,
            y: randomPoint.y)
    }
    
    private func randomColor() -> UIColor {
        let hue = randomForColors.nextUnitDouble() * 0.2 + 0.5
        return UIColor(hue: CGFloat(hue), saturation: 0.7, brightness: 0.9, alpha: 1)
    }
}

extension SIMD2 where Scalar == Double {
    var cgPoint: CGPoint {
        return CGPoint(x: x, y: y)
    }
}

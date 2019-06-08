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
    @IBOutlet weak var bordersBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var polygonsBarButtonItem: UIBarButtonItem!
    
    let fortunesAlgorithmStopWatch = StopWatch(name: "FortunesAlgorithm")
    
    let randomForPoints = Random(mode: .randomlySeeded)
    let randomForColors = Random(mode: .randomlySeeded)
    
    var touchLocation = CGPoint.zero
    
    let pointsSeed = 5
    
    var sitePoints: [SitePoint<UIColor>] = []
    
    var options: Set<Voronoi.Option> = []
    
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
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleGestureRecognizer))
        gestureRecognizer.minimumPressDuration = 0
        
        renderView.addGestureRecognizer(gestureRecognizer)
        renderView.isUserInteractionEnabled = true
        
        updateBarButtonItems()

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
    
    private func updateBarButtonItems() {
        bordersBarButtonItem.title = options.contains(.makeEdgesOnClipRectBorders) ? "Borders ON" : "Borders OFF"
        polygonsBarButtonItem.title = options.contains(.makeSitePolygonVertices) ? "Polygons ON" : "Polygons OFF"
    }
    
    @IBAction func didTapRefreshButton(_ sender: Any) {
        makeSites(forViewSize: renderAreaSize)
        makeNewVoronoi(ofSize: renderAreaSize)
    }
    
    @IBAction func didTapBordersBarButton(_ sender: Any) {
        if options.contains(.makeEdgesOnClipRectBorders) {
            options.remove(.makeEdgesOnClipRectBorders)
        } else {
            options.insert(.makeEdgesOnClipRectBorders)
        }
        
        updateBarButtonItems()
        makeNewVoronoi(ofSize: renderAreaSize)
    }
    
    @IBAction func didTapPolygonsBarButton(_ sender: Any) {
        if options.contains(.makeSitePolygonVertices) {
            options.remove(.makeSitePolygonVertices)
        } else {
            options.insert(.makeSitePolygonVertices)
        }
        
        updateBarButtonItems()
        makeNewVoronoi(ofSize: renderAreaSize)
    }
    
    @objc private func handleGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .began {
            touchLocation = gestureRecognizer.location(ofTouch: 0, in: renderView)
            
            let site = SitePoint(point: SIMD2<Double>(x: Double(touchLocation.x), y: Double(touchLocation.y)), userData: randomColor())
            sitePoints.append(site)
            makeNewVoronoi(ofSize: renderAreaSize)
        } else if gestureRecognizer.state == .changed {
            touchLocation = gestureRecognizer.location(ofTouch: 0, in: renderView)
            let lastPoint = sitePoints.last!
            sitePoints[sitePoints.count-1] = SitePoint(point: SIMD2<Double>(x: Double(touchLocation.x), y: Double(touchLocation.y)), userData: lastPoint.userData)
            makeNewVoronoi(ofSize: renderAreaSize)
        }
    }
    
    private func makeSites(forViewSize size: CGSize) {
        let numberOfSites = 10
        
        Random.setGlobalSeed(pointsSeed)
        
        sitePoints = []
        
        for _ in 0..<numberOfSites {
            let point = randomPointInArea(withSize: size)
            let color = randomColor()
            sitePoints.append(SitePoint(point: point, userData: color))
        }
    }
    
    private func makeNewVoronoi(ofSize size: CGSize) {
        fortunesAlgorithmStopWatch.run({ () -> (edges: [Edge<UIColor>], sites: [Site<UIColor>]) in
            let width = Double(size.width)
            let height = Double(size.height)
            let padding = 10.0
            let result = Voronoi.runFortunesAlgorithm(sitePoints: sitePoints, clipRect: .minMaxXY(minX: padding, minY: padding, maxX: width - padding, maxY: height - padding), options: options)
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

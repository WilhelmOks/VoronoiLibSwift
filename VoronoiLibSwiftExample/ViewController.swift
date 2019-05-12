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
    
    let pointsSeed = 1
    
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
    
    private func makeSites(forViewSize size: CGSize) -> [Site<UIColor>] {
        let numberOfSites = 50
        var sites: [Site<UIColor>] = []
        
        for _ in 0..<numberOfSites {
            let point = randomPointInArea(withSize: size)
            let color = randomColor()
            //let color = UIColor.red
            sites.append(Site(point: point, userData: color))
        }
        
        return sites
    }
    
    private func makeNewVoronoi(ofSize size: CGSize) {
        Random.setGlobalSeed(pointsSeed)
        
        let sites = makeSites(forViewSize: size)
        renderView.sites = sites
        
        fortunesAlgorithmStopWatch.run({ () -> [Edge<UIColor>] in
            let width = Double(size.width)
            let height = Double(size.height)
            let edges = FortunesAlgorithm.run(sites: sites, clipArea: .sizeXY(x: width, y: height), options: [.calculateCellPolygons, .edgesAlsoOnClipAreaBorders])
            return edges
        }) { (result, runTime) in
            fortunesAlgorithmStopWatch.printRunTime(runTime)
            fortunesAlgorithmStopWatch.printAverageRunTime()
            renderView.edges = result.map { (start: $0.start.cgPoint, end: $0.end.cgPoint) }
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

# VoronoiLibSwift
Swift implementation of Fortunes Algorithm.

This is a port of [Zalgo2462/VoronoiLib](https://github.com/Zalgo2462/VoronoiLib) from C# to Swift.
In addition to the original C# library, this Swift library optionally generates polygons for the sites.

![screenshot](Simulator_Screen_Shot.png)

## Xcode projects
* *VoronoiLibSwift.xcodeproj* builds an iOS framework to be used as a library.
* *VoronoiLibSwiftExample.xcodeproj* includes the VoronoiLibSwift framework and contains an example iOS App which renders a voronoi graph.

## Usage

```swift
let sitePoints: [SitePoint<Void>] = [
  SitePoint(point: SIMD2<Double>(x: 20, y: 30)),
  //other site points...
]

let clipRect = ClipRect.minMaxXY(minX: 0, minY: 0, maxX: 50, maxY: 50)

let result = Voronoi.runFortunesAlgorithm(sitePoints: sitePoints, clipRect: clipRect, options: [])
```

![screenshot](bn_pn.png)

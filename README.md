# VoronoiLibSwift
Swift implementation of Fortunes Algorithm.

This is a port of [Zalgo2462/VoronoiLib](https://github.com/Zalgo2462/VoronoiLib) from C# to Swift.
In addition to the original C# library, this Swift library optionally generates polygons for the sites.

![screenshot](Simulator_Screen_Shot.png)

## Xcode projects
* *VoronoiLibSwift.xcodeproj* builds an iOS framework to be used as a library.
* *VoronoiLibSwiftExample.xcodeproj* includes the VoronoiLibSwift framework and contains an example iOS App which renders a voronoi graph.

## Usage

Make an array of `SitePoint<UserData>`. The generic parameter `UserData` can be `Void` if you only need the edges.
Specify a location for each site point by passing a `SIMD2<Double>` x,y coordinates value.
Make a `ClipRect` which will define the borders of the voronoi graph.
Call `Voronoi.runFortunesAlgorithm` and pass the site points and the clipRect as arguments (and an empty Option set for the `options` parameter).

```swift
let sitePoints: [SitePoint<Void>] = [
  SitePoint(point: SIMD2<Double>(x: 20, y: 30)),
  //other site points...
]

let clipRect = ClipRect.minMaxXY(minX: 0, minY: 0, maxX: 50, maxY: 50)

let result = Voronoi.runFortunesAlgorithm(sitePoints: sitePoints, clipRect: clipRect, options: [])
```

The result will be a tuple, containing the sites and the edges for the voronoi graph:
`(edges: [Edge<Void>], sites: [Site<Void>])`

The edges can be rendered like this:
![screenshot](bn_pn.png)

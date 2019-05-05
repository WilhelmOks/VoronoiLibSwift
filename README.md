# VoronoiLibSwift
Swift implementation of Fortunes Algorithm.

This is a port of [Zalgo2462/VoronoiLib](https://github.com/Zalgo2462/VoronoiLib) from C# to Swift.

![screenshot](Simulator_Screen_Shot.png)

## Version 0.1
In the current version 0.1 the swift library is essentially the same code as the original C# library.
The code has been ported by hand. Some minor changes needed to be made in order to work in Swift.

### Xcode projects
* *VoronoiLibSwift.xcodeproj* builds an iOS framework to be used as a library.
* *VoronoiLibSwiftExample.xcodeproj* includes the VoronoiLibSwift framework and contains an example iOS App which renders a voronoi graph.

## TODO for Version 1.0
In addition to the existing code and features of the original C# library, this Swift library will provide the following extras:
* :white_check_mark: ~~Make the public interface more "Swifty".~~
* :white_check_mark: ~~Decouple public interface types from internal types.~~
* Provide the option for the algorithm to generate all the edge info for a site. That will allow to easily generate Polygons sorrounding sites.
* Profile the code and refactor for performance.
* Provide a Framework for macOS (in addition to iOS). Add an example project for macOS.

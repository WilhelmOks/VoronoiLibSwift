# VoronoiLibSwift
Swift implementation of Fortunes Algorithm.

This is a port of [Zalgo2462/VoronoiLib](https://github.com/Zalgo2462/VoronoiLib) from C# to Swift.

## Version 0.1
In the current version 0.1 the swift library is essentially the same code as the original C# library.
The code has been ported by hand. Some minor changes needed to be made in order to work in Swift.

## TODO for Version 1.0
In addition to the existing code and features of the original C# library, this Swift library will provide the following extras:
* Make the public interface more "Swifty".
* Decouple public interface types from internal types.
* Provide the option for the algorithm to generate all the edge info for a site. That will allow to easily generate Polygons sorrounding sites.
* Review the usage of reference types vs. value types to optimize the code for Swift and boost runtime performance.

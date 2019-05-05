//
//  Site.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 19.04.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

public final class Site<UserData> {
    internal let fortuneSite: FortuneSite
    
    public let userData: UserData?
    
    public var point: SIMD2<Double> {
        return fortuneSite.point
    }
    
    public var neighbors: [Site] {
        return fortuneSite.neighbors.map { $0.publicSite as! Site<UserData> }
    }
    
    internal(set) public var polygon: [SIMD2<Double>] = []
    
    public init(point: SIMD2<Double>, userData: UserData? = nil) {
        self.userData = userData
        self.fortuneSite = FortuneSite(point)
        self.fortuneSite.publicSite = self
    }
}

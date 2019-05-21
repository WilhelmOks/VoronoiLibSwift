//
//  SitePoint.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 18.05.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

import Foundation

public struct SitePoint<UserData> {
    public let point: SIMD2<Double>
    public let userData: UserData?
    
    public init(point: SIMD2<Double>, userData: UserData? = nil) {
        self.point = point
        self.userData = userData
    }
}

extension SitePoint : Hashable {
    public static func == (lhs: SitePoint<UserData>, rhs: SitePoint<UserData>) -> Bool {
        return Approx.approxEqual(lhs.point.x, rhs.point.x) && Approx.approxEqual(lhs.point.y, rhs.point.y)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(point.x)
        hasher.combine(point.y)
    }
}

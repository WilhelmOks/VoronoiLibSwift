//
//  SitePoint.swift
//  VoronoiLib
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

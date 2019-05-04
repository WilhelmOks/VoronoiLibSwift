//
//  FortuneSiteEvent.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 19.04.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

final class FortuneSiteEvent : FortuneEvent {
    override var point: VPoint {
        return site.point
    }
    
    let site: FortuneSite
    
    init(_ site: FortuneSite) {
        self.site = site
    }
}

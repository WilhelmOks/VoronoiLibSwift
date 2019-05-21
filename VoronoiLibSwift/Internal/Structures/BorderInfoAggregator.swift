//
//  BorderInfoAggregator.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 21.05.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

final class BorderInfoAggregator {
    var sites: Set<FortuneSite> = []
    var enabled = false
    
    func add(point: VPoint, forSite site: FortuneSite, onBorder border: ClipRect.Border) {
        sites.insert(site)
        site.add(point: point, forBorder: border)
    }
}

//
//  FortuneCircleEvent.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 19.04.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

final class FortuneCircleEvent : FortuneEvent, Hashable {
    override var point: VPoint {
        return lowest
    }
    
    let lowest: VPoint
    let yCenter: Double
    let toDelete: RBTreeNode<BeachSection>
    
    init(lowest: VPoint, yCenter: Double, toDelete: RBTreeNode<BeachSection>) {
        self.lowest = lowest
        self.yCenter = yCenter
        self.toDelete = toDelete
    }
    
    static func < (lhs: FortuneCircleEvent, rhs: FortuneCircleEvent) -> Bool {
        return lhs.compareTo(rhs) < 0
    }
    
    static func == (lhs: FortuneCircleEvent, rhs: FortuneCircleEvent) -> Bool {
        return lhs.compareTo(rhs) == 0
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(point.x)
        hasher.combine(point.y)
    }
}

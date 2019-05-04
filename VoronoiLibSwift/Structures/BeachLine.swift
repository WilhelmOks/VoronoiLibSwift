//
//  BeachLine.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 19.04.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

import simd

final class BeachSection {
    let site: FortuneSite
    var edge: VEdge?
    //NOTE: this will change
    var circleEvent: FortuneCircleEvent?
    
    init(site: FortuneSite) {
        self.site = site
    }
}

final class BeachLine {
    private let beachLine = RBTree<BeachSection>()
    
    init() {
        
    }
    
    func addBeachSection(siteEvent: FortuneSiteEvent, eventQueue: MinHeap<FortuneEvent>, deleted: HashSet<FortuneCircleEvent>, edges: LinkedList<VEdge>) {
        let site = siteEvent.site
        let x = site.point.x
        let directrix = site.point.y
    
        var leftSection: RBTreeNode<BeachSection>? = nil
        var rightSection: RBTreeNode<BeachSection>? = nil
        var node = beachLine.root
    
        //find the parabola(s) above this site
        while node != nil && leftSection == nil && rightSection == nil {
            let distanceLeft = BeachLine.leftBreakpoint(node: node!, directrix: directrix) - x
            if distanceLeft > 0 {
                //the new site is before the left breakpoint
                if node?.left == nil {
                    rightSection = node
                } else {
                    node = node?.left
                }
                continue
            }
    
            let distanceRight = x - BeachLine.rightBreakpoint(node: node!, directrix: directrix)
            if distanceRight > 0 {
                //the new site is after the right breakpoint
                if node?.right == nil {
                    leftSection = node
                } else {
                    node = node?.right
                }
                continue
            }
    
            //the point lies below the left breakpoint
            if ParabolaMath.approxZero(distanceLeft) {
                leftSection = node?.previous
                rightSection = node
                continue
            }
    
            //the point lies below the right breakpoint
            if ParabolaMath.approxZero(distanceRight) {
                leftSection = node
                rightSection = node?.next
                continue
            }
    
            // distance Right < 0 and distance Left < 0
            // this section is above the new site
            leftSection = node
            rightSection = node
        }
    
        //our goal is to insert the new node between the
        //left and right sections
        let section = BeachSection(site: site)
    
        //left section could be nil, in which case this node is the first
        //in the tree
        let newSection = beachLine.insertSuccessor(successorNode: leftSection, successorData: section)
    
        //new beach section is the first beach section to be added
        if leftSection == nil && rightSection == nil {
            return
        }
    
        //main case:
        //if both left section and right section point to the same valid arc
        //we need to split the arc into a left arc and a right arc with our
        //new arc sitting in the middle
        if leftSection != nil && leftSection === rightSection {
            //if the arc has a circle event, it was a false alarm.
            //remove it
            if let leftSectionDataCircleEvent = leftSection!.data.circleEvent {
                deleted.add(leftSectionDataCircleEvent)
                leftSection?.data.circleEvent = nil
            }
        
            //we leave the existing arc as the left section in the tree
            //however we need to insert the right section defined by the arc
            let copy = BeachSection(site: leftSection!.data.site)
            rightSection = beachLine.insertSuccessor(successorNode: newSection, successorData: copy)
        
            //grab the projection of this site onto the parabola
            let y = ParabolaMath.evalParabola(focus: leftSection!.data.site.point, directrix: directrix, x: x)
            let intersection = VPoint(x: x, y: y)
        
            //create the two half edges corresponding to this intersection
            let leftEdge = VEdge(start: intersection, left: site, right: leftSection!.data.site)
            let rightEdge = VEdge(start: intersection, left: leftSection!.data.site, right: site)
            leftEdge.neighbor = rightEdge
        
            //put the edge in the list
            edges.addFirst(leftEdge)
        
            //store the left edge on each arc section
            newSection.data.edge = leftEdge
            rightSection?.data.edge = rightEdge
        
            //store neighbors for delaunay
            leftSection?.data.site.neighbors.append(newSection.data.site)
            newSection.data.site.neighbors.append(leftSection!.data.site)
        
            //create circle events
            BeachLine.checkCircle(section: leftSection!, eventQueue: eventQueue)
            BeachLine.checkCircle(section: rightSection!, eventQueue: eventQueue)
        }
    
        //site is the last beach section on the beach line
        //this can only happen if all previous sites
        //had the same y value
        else if leftSection != nil && rightSection == nil {
            //let minValue = -1.7976931348623157E+308
            let minValue = -Double.greatestFiniteMagnitude
            let start = VPoint(x: (leftSection!.data.site.point.x + site.point.x) * 0.5, y: minValue)
            let infEdge = VEdge(start: start, left: leftSection!.data.site, right: site)
            let newEdge = VEdge(start: start, left: site, right: leftSection!.data.site)
        
            newEdge.neighbor = infEdge
            edges.addFirst(newEdge)
        
            leftSection?.data.site.neighbors.append(newSection.data.site)
            newSection.data.site.neighbors.append(leftSection!.data.site)
        
            newSection.data.edge = newEdge
        
            //cant check circles since they are colinear
        }
    
        //site is directly above a break point
        else if leftSection != nil && leftSection !== rightSection {
            //remove false alarms
            if leftSection!.data.circleEvent != nil {
                deleted.add(leftSection!.data.circleEvent!)
                leftSection!.data.circleEvent = nil
            }
    
            if rightSection?.data.circleEvent != nil {
                deleted.add(rightSection!.data.circleEvent!)
                rightSection!.data.circleEvent = nil
            }
    
            //the breakpoint will dissapear if we add this site
            //which means we will create an edge
            //we treat this very similar to a circle event since
            //an edge is finishing at the center of the circle
            //created by circumscribing the left center and right
            //sites
        
            //bring a to the origin
            let leftSite = leftSection!.data.site
            let a = leftSite.point
            let b = site.point - a
        
            let rightSite = rightSection!.data.site
            let c = rightSite.point - a
            let d2 = (b.x*c.y - b.y*c.x) * 2
            let magnitudeB = simd_length_squared(b) // bx*bx + by*by
            let magnitudeC = simd_length_squared(c) // cx*cx + cy*cy
            
            let vertex = VPoint(
                x: (c.y * magnitudeB - b.y * magnitudeC) / d2 + a.x,
                y: (b.x * magnitudeC - c.x * magnitudeB) / d2 + a.y)
        
            rightSection!.data.edge?.end = vertex
        
            //next we create a two new edges
            newSection.data.edge = VEdge(start: vertex, left: site, right: leftSection!.data.site)
            rightSection?.data.edge = VEdge(start: vertex, left: rightSection!.data.site, right: site)
            
            edges.addFirst(newSection.data.edge!)
            edges.addFirst(rightSection!.data.edge!)
        
            //add neighbors for delaunay
            newSection.data.site.neighbors.append(leftSection!.data.site)
            leftSection!.data.site.neighbors.append(newSection.data.site)
        
            newSection.data.site.neighbors.append(rightSection!.data.site)
            rightSection!.data.site.neighbors.append(newSection.data.site)
        
            BeachLine.checkCircle(section: leftSection!, eventQueue: eventQueue)
            BeachLine.checkCircle(section: rightSection!, eventQueue: eventQueue)
        }
    }
    
    func removeBeachSection(circle: FortuneCircleEvent, eventQueue: MinHeap<FortuneEvent>, deleted: HashSet<FortuneCircleEvent>, edges: LinkedList<VEdge>) {
        let section = circle.toDelete
        let x = circle.point.x
        let y = circle.yCenter
        let vertex = VPoint(x: x, y: y)
    
        //multiple edges could end here
        var toBeRemoved = Array<RBTreeNode<BeachSection>>()
    
        //look left
        var prev = section.previous!
        while prev.data.circleEvent != nil &&
        ParabolaMath.approxEqual(prev.data.circleEvent!.point.x, x) &&
            ParabolaMath.approxEqual(prev.data.circleEvent!.point.y, y) {
            toBeRemoved.append(prev)
            prev = prev.previous!
        }
    
        var next = section.next!
        while next.data.circleEvent != nil &&
        ParabolaMath.approxEqual(next.data.circleEvent!.point.x, x) &&
        ParabolaMath.approxEqual(next.data.circleEvent!.point.y, y) {
            toBeRemoved.append(next)
            next = next.next!
        }
    
        section.data.edge?.end = vertex
        section.next?.data.edge?.end = vertex
        section.data.circleEvent = nil
    
        //odds are this double writes a few edges but this is clean...
        for remove in toBeRemoved {
            remove.data.edge?.end = vertex
            remove.next?.data.edge?.end = vertex
            deleted.add(remove.data.circleEvent!)
            remove.data.circleEvent = nil
        }
    
        //need to delete all upcoming circle events with this node
        if prev.data.circleEvent != nil {
            deleted.add(prev.data.circleEvent!)
            prev.data.circleEvent = nil
        }
        if next.data.circleEvent != nil {
            deleted.add(next.data.circleEvent!)
            next.data.circleEvent = nil
        }
    
        //create a new edge with start point at the vertex and assign it to next
        let newEdge = VEdge(start: vertex, left: next.data.site, right: prev.data.site)
        next.data.edge = newEdge
        edges.addFirst(newEdge)
    
        //add neighbors for delaunay
        prev.data.site.neighbors.append(next.data.site)
        next.data.site.neighbors.append(prev.data.site)
    
        //remove the sectionfrom the tree
        beachLine.removeNode(section)
        for remove in toBeRemoved {
            beachLine.removeNode(remove)
        }
    
        BeachLine.checkCircle(section: prev, eventQueue: eventQueue)
        BeachLine.checkCircle(section: next, eventQueue: eventQueue)
    }
    
    private static func leftBreakpoint(node: RBTreeNode<BeachSection>, directrix: Double) -> Double {
        let leftNode = node.previous
        //degenerate parabola
        if ParabolaMath.approxEqual(node.data.site.point.y, directrix) {
            return node.data.site.point.x
        }
        //node is the first piece of the beach line
        if leftNode == nil {
            return -Double.infinity
        }
        //left node is degenerate
        if ParabolaMath.approxEqual(leftNode!.data.site.point.y, directrix) {
            return leftNode!.data.site.point.x
        }
        let site = node.data.site
        let leftSite = leftNode!.data.site
        return ParabolaMath.intersectParabolaX(focus1: leftSite.point, focus2: site.point, directrix: directrix)
    }
    
    private static func rightBreakpoint(node: RBTreeNode<BeachSection>, directrix: Double) -> Double {
        let rightNode = node.next
        //degenerate parabola
        if ParabolaMath.approxEqual(node.data.site.point.y, directrix) {
            return node.data.site.point.x
        }
        //node is the last piece of the beach line
        if rightNode == nil {
            return Double.infinity
        }
        //left node is degenerate
        if ParabolaMath.approxEqual(rightNode!.data.site.point.y, directrix) {
            return rightNode!.data.site.point.x
        }
        let site = node.data.site
        let rightSite = rightNode!.data.site
        return ParabolaMath.intersectParabolaX(focus1: site.point, focus2: rightSite.point, directrix: directrix)
    }
    
    private static func checkCircle(section: RBTreeNode<BeachSection>, eventQueue: MinHeap<FortuneEvent>) {
        //if (section == nil)
        //    return
        let left = section.previous
        let right = section.next
        if left == nil || right == nil {
            return
        }
    
        let leftSite = left!.data.site
        let centerSite = section.data.site
        let rightSite = right!.data.site
    
        //if the left arc and right arc are defined by the same
        //focus, the two arcs cannot converge
        if leftSite === rightSite {
            return
        }
    
        // http://mathforum.org/library/drmath/view/55002.html
        // because every piece of this program needs to be demoed in maple >.<
    
        //MATH HACKS: place center at origin and
        //draw vectors a and c to
        //left and right respectively
        let b = centerSite.point
        let a = leftSite.point - b
        let c = rightSite.point - b
    
        //The center beach section can only dissapear when
        //the angle between a and c is negative
        let d = a.x*c.y - a.y*c.x
        if ParabolaMath.approxGreaterThanOrEqualTo(d, 0) {
            return
        }
    
        let d2 = d * 2
        
        let magnitudeA = simd_length_squared(a) // ax*ax + ay*ay
        let magnitudeC = simd_length_squared(c) // cx*cx + cy*cy
        let x = (c.y * magnitudeA - a.y * magnitudeC) / d2
        let y = (a.x * magnitudeC - c.x * magnitudeA) / d2
        let point = VPoint(x, y)
    
        //add back offset
        let ycenter = y + b.y
        //y center is off
        let circleEvent = FortuneCircleEvent(
            //lowest: VPoint(x: x + b.x, y: ycenter + sqrt(x * x + y * y)),
            lowest: VPoint(x: x + b.x, y: ycenter + simd_length(point)),
            yCenter: ycenter,
            toDelete: section
        )
        section.data.circleEvent = circleEvent
        let _ = eventQueue.insert(circleEvent)
    }
}

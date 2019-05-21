//
//  MinHeap.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 19.04.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

final class MinHeap<T : AnyObject> where T : FortuneComparable {
    private var items: [T?]
    let capacity: Int
    private(set) var count: Int
    
    init(capacity: Int) {
        if capacity < 2 {
            self.capacity = 2
        } else {
            self.capacity = capacity
        }
        items = Array<T?>(repeating: nil, count: capacity)
        count = 0
    }
    
    public func insert(_ obj: T) -> Bool {
        if count == capacity {
            return false
        }
        items[count] = obj
        count += 1
        percolateUp(count - 1)
        return true
    }
    
    public func pop() -> T? {
        if count == 0 {
            fatalError("Min heap is empty")
        }
        if count == 1 {
            count -= 1
            return items[count]
        }
    
        let min = items[0]
        items[0] = items[count - 1]
        count -= 1
        percolateDown(0)
        return min
    }
    
    public func peek() -> T? {
        if count == 0 {
            fatalError("Min heap is empty")
        }
        return items.first! //items[0]
    }
    
    private func percolateDown(_ indexArgument: Int) {
        var index = indexArgument
        while true {
            let left = 2*index + 1
            let right = 2*index + 2
            var largest = index
    
            if left < count && leftLessThanRight(left, largest) {
                largest = left
            }
            if right < count && leftLessThanRight(right, largest) {
                largest = right
            }
            if largest == index {
                return
            }
            swap(index, largest)
            index = largest
        }
    }
    
    private func percolateUp(_ indexArgument: Int) {
        var index = indexArgument
        while true {
            if index >= count || index <= 0 {
                return
            }
            let parent = (index - 1)/2
    
            if leftLessThanRight(parent, index) {
                return
            }
            swap(index, parent)
            index = parent
        }
    }
    
    private func leftLessThanRight(_ left: Int, _ right: Int) -> Bool {
        if let itemsLeft = items[left], let itemsRight = items[right] {
            return itemsLeft.compareTo(itemsRight) < 0
        } else {
            return false
        }
    }
    
    private func swap(_ left: Int, _ right: Int) {
        //apparently, this is slower than swapping manually: items.swapAt(left, right)
        
        let temp = items[left]
        items[left] = items[right]
        items[right] = temp
    }
}

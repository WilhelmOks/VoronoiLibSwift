//
//  LinkedList.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 20.04.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

/// A basic wrapper around swift's Array to provide reference (class) semantics for the code in BeachLine.
final class LinkedList<T> where T : Equatable {
    private(set) var array = Array<T>()
    
    @inlinable func addFirst(_ newMember: T) {
        array.insert(newMember, at: 0)
    }
    
    @inlinable func removeAll(_ members: [T]) {
        array.removeAllMembers(members)
    }
}

fileprivate extension Array where Element : Equatable {
    func containsMember(_ member: Element) -> Bool {
        return self.contains { $0 == member }
    }
    
    mutating func removeAllMembers(_ members: [Element]) {
        removeAll { members.containsMember($0) } //TODO: can probably be optimized for performance
    }
}

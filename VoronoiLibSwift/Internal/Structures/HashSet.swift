//
//  HashSet.swift
//  VoronoiLibSwift
//
//  Created by Wilhelm Oks on 20.04.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

/// A basic wrapper around swift's Set to provide reference (class) semantics for the code in BeachLine.
final class HashSet<T> where T : Hashable {
    private var set = Set<T>()
    
    @inlinable func add(_ newMember: T) {
        set.insert(newMember)
    }
    
    @inlinable func contains(_ member: T) -> Bool {
        return set.contains(member)
    }
    
    @inlinable func remove(_ member: T) {
        set.remove(member)
    }
}

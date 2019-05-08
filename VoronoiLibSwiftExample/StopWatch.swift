//
//  StopWatch.swift
//  VoronoiLibSwiftExample
//
//  Created by Wilhelm Oks on 01.05.19.
//  Copyright © 2019 Wilhelm Oks. All rights reserved.
//

import Foundation

final class StopWatch {
    let name: String
    private(set) var runTimeHistory: [TimeInterval] = []
    private(set) var runTimeSum: TimeInterval = 0
    
    init(name: String) {
        self.name = name
    }
    
    func run<T>(_ action: () -> T, completion: (_ result: T, _ runTime: TimeInterval) -> ()) {
        let startedAt = DispatchTime.now()
        let result = action()
        let runTime = TimeInterval(DispatchTime.now().uptimeNanoseconds - startedAt.uptimeNanoseconds) / 1_000_000_000
        runTimeHistory.append(runTime)
        runTimeSum += runTime
        completion(result, runTime)
    }
    
    func printRunTime(_ runTime: TimeInterval) {
        print("\(name) run time: \(runTime)s")
    }
    
    func printAverageRunTime() {
        print("\(name) average run time: \(runTimeSum / TimeInterval(runTimeHistory.count))s")
    }
}

//
//  Day21.swift
//  AdventOfCode2023
//
//  Created by Nikolay Volosatov on 21/12/2023.
//

import Foundation
import Shared

public struct Day21: Day {
    static public let number = 21

    let input: String

    public init(input: String) {
        self.input = input
    }

    private func parse() -> (Pos, [[Bool]]) {
        var start: Pos?
        let map = input
            .split(separator: "\n")
            .enumerated()
            .map { (y, line) in
                line
                    .enumerated()
                    .map { (x, ch) in
                        if ch == "S" {
                            start = .init(x: x, y: y)
                        }
                        return ch == "#"
                    }
            }
        return (start!, map)
    }

    public func part01() -> String {
        let (start, map) = parse()
        let targetSteps = map.count < 20 ? 6 : 64
        var queue = [start]
        var nextQueue = Set<Pos>()
        for _ in 0..<targetSteps {
            for pos in queue {
                for dir in Dir.allCases {
                    let next = pos + dir.delta
                    guard map.at(next) == false else { continue }
                    nextQueue.insert(next)
                }
            }
            queue = Array(nextQueue)
            nextQueue.removeAll()
        }
        return "\(queue.count)"
    }

    public func part02() -> String {
        let (start, map) = parse()
        let (h, w) = (map.count, map.first!.count)
        let targetSteps = map.count < 20 ? 5000 : 26501365
        var queue = Set<Pos>([start])
        var progression: [Int] = []
        for step in 0..<targetSteps {
            var nextQueue = Set<Pos>()
            for pos in queue {
                for dir in Dir.allCases {
                    let next = pos + dir.delta
                    guard map.at(next.wrap(w: w, h: h)) == false else { continue }
                    nextQueue.insert(next)
                }
            }

            if (step % h) == (targetSteps % h) {
                progression.append(queue.count)
                guard progression.count != 3 else {
                    let n = targetSteps / map.count
                    let a = progression[0]
                    let b = progression[1] - progression[0]
                    let c = progression[2] - 2 * progression[1] + progression[0]
                    let result = a + b * n + c * (n * (n - 1) / 2)
                    return "\(result)"
                }
            }
            queue = nextQueue
        }
        fatalError()
    }
}

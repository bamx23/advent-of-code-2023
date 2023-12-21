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
        let allMaps = AllMaps()
        let center = MapPart(map: map, mapPos: .init(x: 0, y: 0), allMaps: allMaps)
        center.startAt(start)

        let targetSteps = map.count < 20 ? 5000 : 26501365
        for step in 0..<targetSteps {
            switch step {
            case 6, 10, 50, 100, 500, 1000, 5000: print("\(step): \(allMaps.totalCount(step))")
            default: break
            }

            for map in allMaps.nonFinishedMaps.values {
                map.tick()
            }
            for map in Array(allMaps.nonFinishedMaps.values) {
                map.tock(step)
            }
        }
        return "\(allMaps.totalCount(targetSteps))"
    }
}

private class AllMaps {
    var oddCount = 0
    var evenCount = 0

    var maps: [Pos: MapPart] = [:]
    var nonFinishedMaps: [Pos: MapPart] = [:]

    func totalCount(_ stepIndex: Int) -> Int {
        (stepIndex % 2 == 0 ? evenCount : oddCount)
        + nonFinishedMaps.values.map { $0.queue.count }.reduce(0, +)
    }
}

private class MapPart {
    let map: [[Bool]]
    let w: Int
    let h: Int

    let mapPos: Pos

    var nbs: [Dir: MapPart] = [:]

    private let allMaps: AllMaps

    private(set) var queue = Set<Pos>()
    private var nextQueue = Set<Pos>()

    private var isComplete = false
    private var extraRepeats = Int.max
    private var stateA = Set<Pos>([.init(x: Int.max, y: Int.max)])
    private var stateB = Set<Pos>([.init(x: Int.max, y: Int.max)])

    init(map: [[Bool]], mapPos: Pos, allMaps: AllMaps) {
        self.map = map
        self.mapPos = mapPos
        self.allMaps = allMaps

        self.h = map.count
        self.w = map.first!.count

        allMaps.maps[mapPos] = self
        allMaps.nonFinishedMaps[mapPos] = self
    }

    func startAt(_ pos: Pos) {
        queue.insert(pos)
    }

    func tick() {
        for pos in queue {
            for dir in Dir.allCases {
                let delta = dir.delta
                let next = pos + delta
                guard let val = map.at(next) else {
                    // Outside this map
                    let nb = getOrCreateNb(dir)
                    if nb.isComplete == false {
                        nb.nextQueue.insert(next - .init(x: delta.x * w, y: delta.y * h))
                    }
                    continue
                }
                guard val == false else { continue }
                nextQueue.insert(next)
            }
        }
    }

    func tock(_ step: Int) {
        queue = nextQueue
        nextQueue.removeAll()

//        if mapPos == .init(x: -6, y: 0) {
//            print()
//        }

//        isComplete = isComplete || stateA == queue
//        (stateA, stateB) = (stateB, queue)
//        if isComplete {
//            if extraRepeats == 0 {
//                allMaps.nonFinishedMaps[mapPos] = nil
//                if step % 2 == 0 {
//                    allMaps.evenCount += queue.count
//                    allMaps.oddCount += stateB.count
//                } else {
//                    allMaps.evenCount += stateB.count
//                    allMaps.oddCount += queue.count
//                }
//            }
//            extraRepeats -= 1
//        }
    }

    private func getOrCreateNb(_ dir: Dir) -> MapPart {
        if let other = nbs[dir] {
            return other
        }

        let other = MapPart(map: map, mapPos: mapPos + dir.delta, allMaps: allMaps)

        let rev = dir.rev
        nbs[dir] = other
        other.nbs[rev] = self
        switch dir {
        case .left, .right:
            if let n = nbs[.up]?.nbs[dir] {
                n.nbs[.down] = other
                other.nbs[.up] = n
            }
            if let n = nbs[.down]?.nbs[dir] {
                n.nbs[.up] = other
                other.nbs[.down] = n
            }
            break
        case .up, .down:
            if let n = nbs[.left]?.nbs[dir] {
                n.nbs[.right] = other
                other.nbs[.left] = n
            }
            if let n = nbs[.right]?.nbs[dir] {
                n.nbs[.left] = other
                other.nbs[.right] = n
            }
            break
        }
        return other
    }

    private func findCounts(counts: inout [Pos: Int]) {
        guard counts[mapPos] == nil else { return }
        counts[mapPos] = queue.count
        nbs.values.forEach { $0.findCounts(counts: &counts) }
    }

    func totalQueueSize() -> Int {
        var counts = [Pos: Int]()
        findCounts(counts: &counts)
//        print(counts)
        return counts.values.reduce(0, +)
    }

    func print() {
        let str = (0..<h)
            .map { y in
                String((0..<w)
                    .map { x -> Character in
                        if queue.contains(.init(x: x, y: y)) {
                            return "O"
                        }
                        return map[y][x] ? "#" : "."
                    })
            }
            .joined(separator: "\n")
        Swift.print(str + "\n\n")
    }
}

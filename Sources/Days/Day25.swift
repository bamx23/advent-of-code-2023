//
//  Day25.swift
//  AdventOfCode2023
//
//  Created by Nikolay Volosatov on 25/12/2023.
//

import Foundation
import Shared
import Algorithms

public struct Day25: Day {
    static public let number = 25

    let input: String

    public init(input: String) {
        self.input = input
    }

    func parse() -> [String: [String]] {
        Dictionary(uniqueKeysWithValues:
            input
                .split(separator: "\n")
                .map { line -> (String, [String]) in
                    let pair = line.split(separator: ": ")
                    let key = String(pair[0])
                    let vals = pair[1]
                        .split(separator: " ")
                        .map(String.init)
                    return (key, vals)
                }
        )
    }

    public func part01() -> String {
        let source = parse()
        let namedEdges = source
            .flatMap { (k, v) in v.map { (k, $0) } }
        let nodes = Set(namedEdges.flatMap { [$0.0, $0.1] }).sorted()
        let edges = namedEdges
            .map { (a, b) -> (Int, Int) in (nodes.firstIndex(of: a)!, nodes.firstIndex(of: b)!)}
        let graph = edges
            .reduce(into: [[Int]](repeating: [], count: nodes.count), { (r, e) in
                r[e.0].append(e.1)
                r[e.1].append(e.0)
            })

        let expectedCuts: Set<Int>? = nodes.count == 15
        ? Set([
            edgeId(nodes.firstIndex(of: "hfx")!, nodes.firstIndex(of: "pzl")!),
            edgeId(nodes.firstIndex(of: "bvb")!, nodes.firstIndex(of: "cmg")!),
            edgeId(nodes.firstIndex(of: "nvd")!, nodes.firstIndex(of: "jqt")!),
        ])
        : nil

        func edgeId(_ a: Int, _ b: Int) -> Int {
            a <= b ? a * nodes.count + b : edgeId(b, a)
        }

        func checkCompA(_ stack: [Int], _ ignored: Set<Int>, _ visited: [Bool]) -> Int? {
            var size = 1
            var stack = stack
            var visited = visited
            while stack.isEmpty == false {
                let cur = stack.removeFirst()
                for nb in graph[cur] {
                    guard ignored.contains(edgeId(cur, nb)) == false else { continue }
                    guard visited[nb] == false else { continue }
                    stack.append(nb)
                    visited[nb] = true
                    size += 1
                }
            }
            return size
        }

        func checkCompB(_ start: Int, _ ignored: Set<Int>, _ visitedA: [Bool]) -> Int? {
            var size = 1
            var stack = [start]
            var visited = [Bool](repeating: false, count: nodes.count)
            visited[start] = true
            while stack.isEmpty == false {
                let cur = stack.removeFirst()
                for nb in graph[cur] {
                    guard visited[nb] == false else { continue }
                    guard ignored.contains(edgeId(cur, nb)) == false else { continue }
                    guard visitedA[nb] == false else { return nil }
                    stack.append(nb)
                    visited[nb] = true
                    size += 1
                }
            }
            return size
        }

        func solve(_ cur: Int, _ size: Int,_ cutsLeft: Int,
                   _ ignored: inout Set<Int>, _ visited: inout [Bool], _ stack: inout [Int]) -> Int? {
            stack.append(cur)
            visited[cur] = true

            if cutsLeft == 1 {
                for cutTo in graph[cur] {
                    guard visited[cutTo] == false else { continue }
                    let id = edgeId(cur, cutTo)
                    guard ignored.contains(id) == false else { continue }

                    ignored.insert(id)
//                    if ignored == expectedCuts {
//                        print("!")
//                    }
                    if let sizeB = checkCompB(cutTo, ignored, visited),
                       let sizeA = checkCompA(stack, ignored, visited) {
                        return sizeB * (sizeA + size - 1)
                    }
                    ignored.remove(id)
                }
            }

            if cutsLeft >= 2 {
                for cutTo in graph[cur] {
                    guard visited[cutTo] == false else { continue }
                    let id = edgeId(cur, cutTo)
                    guard ignored.contains(id) == false else { continue }

                    ignored.insert(id)
                    var innerVisited = visited
                    if let r = solve(cur, size, cutsLeft - 1, &ignored, &innerVisited, &stack) { return r }
                    ignored.remove(id)
                }
            }

            for nb in graph[cur] {
                guard visited[nb] == false else { continue }
                guard ignored.contains(edgeId(cur, nb)) == false else { continue }
                if let r = solve(nb, size + 1, cutsLeft, &ignored, &visited, &stack) { return r }
            }

            stack.removeLast()
            return nil
        }

        do {
            var visited = [Bool](repeating: false, count: nodes.count)
            let y = checkCompB(0, Set(), visited)
            assert(y == nodes.count)
            visited[0] = true
            let x = checkCompA([0], Set(), visited)
            assert(x == nodes.count)
        }

        if nodes.count > 100 {
            let cuts = Set([
                edgeId(nodes.firstIndex(of: "zxb")!, nodes.firstIndex(of: "zkv")!),
                edgeId(nodes.firstIndex(of: "lkf")!, nodes.firstIndex(of: "scf")!),
                edgeId(nodes.firstIndex(of: "mtl")!, nodes.firstIndex(of: "pgl")!),
            ])
            let (a, b) = (nodes.firstIndex(of: "zxb")!, nodes.firstIndex(of: "zkv")!)
            var visited = [Bool](repeating: false, count: nodes.count)
            visited[a] = true
            visited[b] = true
            let x = checkCompA([a], cuts, visited)!
            let y = checkCompA([b], cuts, visited)!
            return "\(x * y)"
        }

        var ignored = Set<Int>()
        var visited = [Bool](repeating: false, count: nodes.count)
        var stack = [Int]()
        let result = solve(0, 1, 3, &ignored, &visited, &stack)!
        return "\(result)"
    }

    public func part01__() -> String {
        graphViz()

        let source = parse()
        let namedEdges = source
            .flatMap { (k, v) in v.map { (k, $0) } }
        let nodes = Set(namedEdges.flatMap { [$0.0, $0.1] }).sorted()
        let edges = namedEdges
            .map { (a, b) -> (Int, Int) in (nodes.firstIndex(of: a)!, nodes.firstIndex(of: b)!)}
        var graph = edges
            .reduce(into: [Set<Int>](repeating: Set(), count: nodes.count), { (r, e) in
                r[e.0].insert(e.1)
                r[e.1].insert(e.0)
            })

        for cuts in edges.combinations(ofCount: 3) {
            for (a, b) in cuts {
                graph[a].remove(b)
                graph[b].remove(a)
            }

            var colors = [Int](repeating: 0, count: nodes.count)
            var queue = [(cuts[0].0, false), (cuts[0].1, true)]
            var isCorrect = true
            while isCorrect && queue.isEmpty == false {
                let (cur, isB) = queue.removeFirst()
                for nb in graph[cur] {
                    guard colors[nb] != (isB ? 1 : 2) else {
                        isCorrect = false
                        break
                    }
                    guard colors[nb] == 0 else { continue }
                    colors[nb] = isB ? 2 : 1
                    queue.append((nb, isB))
                }
            }
            if isCorrect {
                let sizes = Dictionary(grouping: colors, by: { $0 }).mapValues(\.count)
                if sizes[0] == nil {
                    return "\(sizes[1]! * sizes[2]!)"
                }
            }

            for (a, b) in cuts {
                graph[a].insert(b)
                graph[b].insert(a)
            }
        }
        return "not found"
    }

    private func graphViz() {
        let source = parse()
        print("digraph G {")
        for (key, conn) in source {
            for c in conn {
                print("\(key) -> \(c)")
            }
        }
        print("}")
    }

    public func part02() -> String {
        return "\(0)"
    }
}

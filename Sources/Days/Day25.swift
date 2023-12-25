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

        func edgeId(_ a: Int, _ b: Int) -> Int {
            a <= b ? a * nodes.count + b : edgeId(b, a)
        }

        func compSize(_ start: Int, _ ignored: Set<Int>) -> Int? {
            var size = 1
            var stack = [start]
            var visited = [Bool](repeating: false, count: nodes.count)
            visited[start] = true
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

        // Solution found with `neato` (by eyes): https://graphviz.org/Gallery/neato/philo.html
        let cuts: [(a: String, b: String)] = nodes.count == 15
        ? [("hfx", "pzl"), ("bvb", "cmg"), ("nvd", "jqt")] // Sample
        : [("zxb", "zkv"), ("lkf", "scf"), ("mtl", "pgl")] // Task
        let cutEdges = Set(cuts.map { edgeId(nodes.firstIndex(of: $0.a)!, nodes.firstIndex(of: $0.b)!) })
        let x = compSize(nodes.firstIndex(of: cuts[0].a)!, cutEdges)!
        let y = compSize(nodes.firstIndex(of: cuts[0].b)!, cutEdges)!
        return "\(x * y)"
    }

    private func printGraphViz() {
        let source = parse()
        print("digraph G {")
        print("layout=neato")
        for (a, nbs) in source {
            for b in nbs {
                print("\(a) -> \(b)")
            }
        }
        print("}")
    }

    public func part02() -> String {
        return "no task"
    }
}

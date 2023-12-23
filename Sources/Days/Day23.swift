//
//  Day23.swift
//  AdventOfCode2023
//
//  Created by Nikolay Volosatov on 23/12/2023.
//

import Foundation
import Shared

public struct Day23: Day {
    static public let number = 23

    let input: String

    enum Tile {
        case path
        case forest
        case slope(Dir)
    }

    public init(input: String) {
        self.input = input
    }

    func parse() -> [[Tile]] {
        input
            .split(separator: "\n")
            .map { $0.map(Tile.parse) }
    }

    private func solve(_ map: [[Tile]]) -> Int {
        let (map, start, target) = reducedMap(map: map)

        func dfs(_ pos: Pos, _ len: Int, _ visited: inout Set<Pos>) -> Int? {
            guard pos != target else { return len }
            guard visited.contains(pos) == false else { return nil }
            var maxLen: Int?
            visited.insert(pos)
            for (nextPos, dist) in map[pos]! {
                if let nextLen = dfs(nextPos, len + dist, &visited) {
                    maxLen = max(nextLen, maxLen ?? 0)
                }
            }
            visited.remove(pos)
            return maxLen
        }
        var visited = Set<Pos>()
        return dfs(start, 0, &visited)!
    }

    private func reducedMap(map: [[Tile]]) -> ([Pos: [Pos: Int]], start: Pos, target: Pos) {
        var result = [Pos: [Pos: Int]]()

        let start = Pos(x: map.first!.firstIndex(where: { $0.isEmpty })!, y: 0)
        let target = Pos(x: map.last!.firstIndex(where: { $0.isEmpty })!, y: map.count - 1)

        func nbs(_ pos: Pos) -> [Pos] {
            Dir.allCases.map { pos + $0.delta }.filter { nPos in
                switch map.at(nPos) {
                case .path, .slope(_): return true
                default: return false
                }
            }
        }

        let junctions = Set(
            map.enumerated()
                .flatMap { y, row in
                    row.enumerated().compactMap { (x, tile) -> Pos? in
                        guard tile.isEmpty else { return nil }
                        let pos = Pos(x: x, y: y)
                        return nbs(pos).count >= 3 ? pos : nil
                    }
                }
            + [start, target]
        )

        for pos in junctions {
            for nStart in nbs(pos) {
                var len = 1
                var isCorrect = true
                var (prev, cur) = (pos, nStart)
                while junctions.contains(cur) == false {
                    if case .slope(let dir) = map.at(cur) {
                        if cur + dir.delta == prev {
                            isCorrect = false
                            break
                        }
                        len += 1
                        (prev, cur) = (cur, cur + dir.delta)
                        continue
                    }
                    len += 1
                    (prev, cur) = (cur, nbs(cur).first(where: { $0 != prev })!)
                }
                if isCorrect {
                    result[pos, default: [:]][cur] = len
                }
            }
        }
        return (result, start, target)
    }

    public func part01() -> String {
        let map = parse()
        let maxRouteLen = solve(map)
        return "\(maxRouteLen)"
    }

    public func part02() -> String {
        let map = parse()
            .map { row in row.map { tile in
                switch tile {
                case .path, .forest: return tile
                case .slope(_): return .path
                }
            }}
        let maxRouteLen = solve(map)
        return "\(maxRouteLen)"
    }
}

extension Day23.Tile {
    static func parse(_ ch: Character) -> Self {
        switch ch {
        case ".": return .path
        case "#": return .forest
        case "^": return .slope(.up)
        case "v": return .slope(.down)
        case ">": return .slope(.right)
        case "<": return .slope(.left)
        default: fatalError("Unknown tile: \(ch)")
        }
    }

    var isEmpty: Bool {
        guard case .path = self else {
            return false
        }
        return true
    }
}

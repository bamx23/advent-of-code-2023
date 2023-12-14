//
//  Day14.swift
//  AdventOfCode2023
//
//  Created by Nikolay Volosatov on 14/12/2023.
//

import Foundation
import Shared

public struct Day14: Day {
    static public let number = 14

    let input: String

    enum Tile {
        case rock
        case wall
        case empty
    }

    public init(input: String) {
        self.input = input
    }

    func parse() -> [[Tile]] {
        input
            .split(separator: "\n")
            .map { $0.map(Tile.parse) }
    }

    public func part01() -> String {
        var map = parse()
        map.tiltUp()
        return "\(map.score())"
    }

    public func part02() -> String {
        typealias Key = [[Tile]]
        var map = parse()
        var memo = [map: 0]
        var count = 0
        let targetCount = 1_000_000_000
        while count < targetCount {
            map.tiltCycle()
            count += 1
            if let prev = memo[map] {
                let loops = (targetCount - count) / (count - prev)
                count += loops * (count - prev)
            } else {
                memo[map] = count
            }
        }
        return "\(map.score())"
    }
}

extension Day14.Tile: CustomStringConvertible {
    static func parse(_ ch: Character) -> Self {
        switch ch {
        case "O": return .rock
        case "#": return .wall
        case ".": return .empty
        default: fatalError("Unknown tile: \(ch)")
        }
    }

    var description: String {
        switch self {
        case .rock:
            return "O"
        case .wall:
            return "#"
        case .empty:
            return "."
        }
    }
}

extension Array where Element == [Day14.Tile] {
    mutating func tiltUp() {
        tiltDir(startPos: Pos(x: 0, y: 0), dir: Pos(x: 0, y: 1), nextLine: Pos(x: 1, y: 0), maxPos: { $0.y < $1.y ? $1 : $0 })
    }

    mutating func tiltCycle() {
        tiltDir(startPos: Pos(x: 0, y: 0), dir: Pos(x: 0, y: 1), nextLine: Pos(x: 1, y: 0), maxPos: { $0.y < $1.y ? $1 : $0 })
        tiltDir(startPos: Pos(x: 0, y: 0), dir: Pos(x: 1, y: 0), nextLine: Pos(x: 0, y: 1), maxPos: { $0.x < $1.x ? $1 : $0 })
        tiltDir(startPos: Pos(x: 0, y: count - 1), dir: Pos(x: 0, y: -1), nextLine: Pos(x: 1, y: 0), maxPos: { $0.y < $1.y ? $0 : $1 })
        tiltDir(startPos: Pos(x: first!.count - 1, y: 0), dir: Pos(x: -1, y: 0), nextLine: Pos(x: 0, y: 1), maxPos: { $0.x < $1.x ? $0 : $1 })
    }

    private func at(_ pos: Pos) -> Day14.Tile? {
        guard 0 <= pos.y && pos.y < count && 0 <= pos.x && pos.x < first!.count else { return nil }
        return self[pos.y][pos.x]
    }

    private mutating func tiltDir(startPos: Pos, dir: Pos, nextLine: Pos, maxPos: (Pos, Pos) -> Pos) {
        var startPos = startPos
        while at(startPos) != nil {
            var emptyPos = startPos
            var nextPos = startPos
            while true {
                while [.wall, .rock].contains(at(emptyPos)) { emptyPos = emptyPos + dir }
                if at(emptyPos) == nil { break }

                nextPos = maxPos(emptyPos + dir, nextPos)
                while at(nextPos) == .empty { nextPos = nextPos + dir }
                if at(nextPos) == nil { break }
                if at(nextPos) == .wall {
                    emptyPos = nextPos + dir
                    continue
                }

                self[emptyPos.y][emptyPos.x] = .rock
                self[nextPos.y][nextPos.x] = .empty
            }
            startPos = startPos + nextLine
        }
    }

    func score() -> Int {
        self
            .reversed()
            .enumerated()
            .map { (idx, line) in (idx + 1) * line.filter({ $0 == .rock }).count }
            .reduce(0, +)
    }

    func print() {
        let text = self
            .map { line in line.map(\.description).joined() }
            .joined(separator: "\n")
        Swift.print(text)
    }
}

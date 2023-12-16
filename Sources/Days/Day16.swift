//
//  Day16.swift
//  AdventOfCode2023
//
//  Created by Nikolay Volosatov on 16/12/2023.
//

import Foundation
import Shared

public struct Day16: Day {
    static public let number = 16

    let input: String

    enum Tile: Character {
        case empty = "."
        case mirrorDown = "\\"
        case mirrorUp = "/"
        case splitH = "-"
        case splitV = "|"
    }

    enum Dir {
        case up
        case down
        case left
        case right
    }

    struct Beam: Hashable {
        var pos: Pos
        var dir: Dir
    }

    public init(input: String) {
        self.input = input
    }

    func parse() -> [[Tile]] {
        input
            .split(separator: "\n")
            .map { $0.compactMap(Tile.init(rawValue:)) }
    }

    private func solve(map: [[Tile]], startBeam: Beam) -> Int {
        var beams = [startBeam]
        var visited = Set(beams)
        while beams.isEmpty == false {
            let beam = beams.removeFirst()
            let newBeams = map.at(beam.pos)!
                .apply(beam)
                .filter { map.at($0.pos) != nil }
                .filter { visited.contains($0) == false }

            beams.append(contentsOf: newBeams)
            visited.formUnion(newBeams)
        }
        let power = Set(visited.map(\.pos)).count
        return power
    }

    public func part01() -> String {
        let map = parse()
        let power = solve(
            map: map,
            startBeam: .init(pos: .init(x: 0, y: 0), dir: .right)
        )
        return "\(power)"
    }

    public func part02() -> String {
        let map = parse()
        let power = map
            .entries()
            .map { solve(map: map, startBeam: $0) }
            .max()!
        return "\(power)"
    }
}

extension Array where Element == [Day16.Tile] {
    func at(_ pos: Pos) -> Day16.Tile? {
        guard 0 <= pos.y && pos.y < count else { return nil }
        let row = self[pos.y]
        guard 0 <= pos.x && pos.x < row.count else { return nil }
        return row[pos.x]
    }

    func entries() -> [Day16.Beam] {
        let (h, w) = (count, first!.count)
        let horizontal = (0..<w)
            .flatMap { x -> [Day16.Beam] in [
                .init(pos: .init(x: x, y: 0), dir: .down),
                .init(pos: .init(x: x, y: h - 1), dir: .up),
            ]}
        let vertical = (0..<h)
            .flatMap { y -> [Day16.Beam] in [
                .init(pos: .init(x: 0, y: y), dir: .right),
                .init(pos: .init(x: w - 1, y: y), dir: .left),
            ]}
        return horizontal + vertical
    }
}

extension Day16.Dir {
    var delta: Pos {
        switch self {
        case .up:       return .init(x: 0, y: -1)
        case .down:     return .init(x: 0, y: 1)
        case .left:     return .init(x: -1, y: 0)
        case .right:    return .init(x: 1, y: 0)
        }
    }
}

extension Day16.Tile {
    func apply(_ beam: Day16.Beam) -> [Day16.Beam] {
        func pass() -> Day16.Beam {
            return .init(pos: beam.pos + beam.dir.delta, dir: beam.dir)
        }
        func redirect(_ dir: Day16.Dir) -> Day16.Beam {
            return .init(pos: beam.pos + dir.delta, dir: dir)
        }

        switch (self, beam.dir) {
        case (.empty, _): return [pass()]

        case (.mirrorUp, .up): return [redirect(.right)]
        case (.mirrorUp, .down): return [redirect(.left)]
        case (.mirrorUp, .left): return [redirect(.down)]
        case (.mirrorUp, .right): return [redirect(.up)]

        case (.mirrorDown, .up): return [redirect(.left)]
        case (.mirrorDown, .down): return [redirect(.right)]
        case (.mirrorDown, .left): return [redirect(.up)]
        case (.mirrorDown, .right): return [redirect(.down)]

        case (.splitH, .left), (.splitH, .right): return [pass()]
        case (.splitH, .up), (.splitH, .down): return [redirect(.left), redirect(.right)]

        case (.splitV, .up), (.splitV, .down): return [pass()]
        case (.splitV, .left), (.splitV, .right): return [redirect(.up), redirect(.down)]
        }
    }
}

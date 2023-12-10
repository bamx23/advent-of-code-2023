//
//  Day10.swift
//  AdventOfCode2023
//
//  Created by Nikolay Volosatov on 10/12/2023.
//

import Foundation
import Shared

public struct Day10: Day {
    static public let number = 10

    let input: String

    enum Tile: CaseIterable {
        case empty
        case vertical
        case horizontal
        case northWest
        case northEast
        case southWest
        case southEast
        case start
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
        let field = parse()
        let sPos = field.enumerated()
            .compactMap { (y, r) in
                r.enumerated()
                    .first(where: { (_, c) in c == .start })
                    .map { (x, _) in Pos(x: x, y: y) }
            }
            .first!

        var cur = sPos
        var next = [(-1, 0), (1, 0), (0, -1), (0, 1)]
            .map(Pos.init)
            .map { $0 + sPos }
            .first(where: { field.at(pos: $0)?.adj(pos: $0).contains(sPos) ?? false })!
        var loop = [cur]
        while next != sPos {
            loop.append(next)
            (cur, next) = (next, field.at(pos: next)!.adj(pos: next).first(where: { $0 != cur })!)
        }
        return "\(loop.count / 2)"
    }

    public func part02() -> String {
        var field = parse()

        let sPos = field.enumerated()
            .compactMap { (y, r) in
                r.enumerated()
                    .first(where: { (_, c) in c == .start })
                    .map { (x, _) in Pos(x: x, y: y) }
            }
            .first!
        let adj = [(-1, 0), (1, 0), (0, -1), (0, 1)]
            .map(Pos.init)
            .map { $0 + sPos }
            .filter { field.at(pos: $0)?.adj(pos: $0).contains(sPos) ?? false }
            .map { $0 - sPos }
        let sTile = Tile.fromAdj(adj)
        field[sPos.y][sPos.x] = sTile

        var cur = sPos
        var next = [(-1, 0), (1, 0), (0, -1), (0, 1)]
            .map(Pos.init)
            .map { $0 + sPos }
            .first(where: { field.at(pos: $0)?.adj(pos: $0).contains(sPos) ?? false })!
        var loop = Set([cur])
        while next != sPos {
            loop.insert(next)
            (cur, next) = (next, field.at(pos: next)!.adj(pos: next).first(where: { $0 != cur })!)
        }

        let (hx, wx) = (field.count * 2, field.first!.count * 2)
        var exField = [[Int]](repeating: [Int](repeating: 0, count: wx), count: hx)
        var groupIdx = 1
        for y in 0..<hx {
            for x in 0..<wx {
                guard exField[y][x] == 0 else { continue }
                var stack = [Pos(x: x, y: y)]
                while stack.isEmpty == false {
                    let pos = stack.removeLast()
                    exField[pos.y][pos.x] = groupIdx
                    for adjPos in field.atx(pos: pos)!.adjx(pos: pos) {
                        guard adjPos.x >= 0 && adjPos.x < wx && adjPos.y >= 0 && adjPos.y < hx else { continue }
                        guard exField[adjPos.y][adjPos.x] == 0 else { continue }
                        stack.append(adjPos)
                    }
                }
                groupIdx += 1
            }
        }

        let fieldGroups = field
            .enumerated()
            .map { (y, row) in
                row.enumerated()
                    .map { (x, tile) in
                        guard loop.contains(.init(x: x, y: y)) == false else { return 0 }
                        let group = exField[y * 2][x * 2]
                        guard exField[y * 2][x * 2 + 1] == group 
                                && exField[y * 2 + 1][x * 2] == group
                                && exField[y * 2 + 1][x * 2 + 1] == group else {
                            return 0
                        }
                        return group
                    }
            }

//        field[sPos.y][sPos.x] = .start
//        let map = field
//            .enumerated()
//            .map { (y, row) in
//                row.enumerated()
//                    .map { (x, tile) in
//                        (fieldGroups[y][x] != 0) ? "\(fieldGroups[y][x])" : "\(tile.debugCh)"
//                    }
//                    .joined()
//            }
//            .joined(separator: "\n")
//        if field.count < 30 {
//            Swift.print(map)
//        }

        let maxGroup = fieldGroups.map { $0.max()! }.max()!
        guard maxGroup != 0 else { return "0" }

        let groups = (1...maxGroup)
            .map { group in fieldGroups.map { r in r.filter { $0 == group }.count }.reduce(0, +) }
            .filter { $0 != 0 }
            .sorted()
        return "\(groups)"
    }
}

private extension Array where Element == [Day10.Tile] {
    func at(pos: Pos) -> Day10.Tile? {
        guard pos.y >= 0 && pos.y < count else { return nil }
        let row = self[pos.y]
        guard pos.x >= 0 && pos.x < row.count else { return nil }
        return row[pos.x]
    }

    func atx(pos: Pos) -> Day10.Tile? {
        at(pos: .init(x: pos.x / 2, y: pos.y / 2))
    }

    func print() {
        let map = self
            .map { String($0.map(\.debugCh)) }
            .joined(separator: "\n")
        Swift.print(map)
    }
}

extension Day10.Tile {
    static func parse(_ ch: Character) -> Self {
        switch ch {
        case ".": return .empty
        case "|": return .vertical
        case "-": return .horizontal
        case "L": return .northEast
        case "J": return .northWest
        case "7": return .southWest
        case "F": return .southEast
        case "S": return .start
        default:
            fatalError("Unknown tile: \(ch)")
        }
    }

    static func fromAdj(_ adj: [Pos]) -> Self {
        Self.allCases.first(where: { Set(adj) == Set($0.deltas()) })!
    }

    private func deltas() -> [Pos] {
        switch self {
        case .empty:        return []
        case .horizontal:   return [.init(x: -1, y:  0), .init(x:  1, y: 0)]
        case .vertical:     return [.init(x:  0, y: -1), .init(x:  0, y: 1)]
        case .northWest:    return [.init(x:  0, y: -1), .init(x: -1, y: 0)]
        case .northEast:    return [.init(x:  0, y: -1), .init(x:  1, y: 0)]
        case .southWest:    return [.init(x:  0, y:  1), .init(x: -1, y: 0)]
        case .southEast:    return [.init(x:  0, y:  1), .init(x:  1, y: 0)]
        case .start:        fatalError()
        }
    }

    func adj(pos: Pos) -> [Pos] {
        deltas().map { $0 + pos }
    }

    private enum Subtype {
        case topLeft
        case topRight
        case botLeft
        case botRight
    }

    private static func posSubtype(_ pos: Pos) -> Subtype {
        switch (pos.y % 2, pos.x % 2) {
        case (0, 0): return .topLeft
        case (0, 1): return .topRight
        case (1, 0): return .botLeft
        case (1, 1): return .botRight
        default: fatalError()
        }
    }

    private func deltax(subtype: Subtype) -> [Pos] {
        let (t, b, l, r) = (Pos(x: 0, y: -1), Pos(x: 0, y: 1), Pos(x: -1, y: 0), Pos(x: 1, y: 0))
        switch (self, subtype) {
        case (.empty, _):               return [t, b, l, r]

        case (.horizontal, .topLeft):   return [t, l, r]
        case (.horizontal, .topRight):  return [t, l, r]
        case (.horizontal, .botLeft):   return [b, l, r]
        case (.horizontal, .botRight):  return [b, l, r]

        case (.vertical, .topLeft):     return [t, b, l]
        case (.vertical, .botLeft):     return [t, b, l]
        case (.vertical, .topRight):    return [t, b, r]
        case (.vertical, .botRight):    return [t, b, r]

        // ┘
        case (.northWest, .topLeft):    return [t, l]
        case (.northWest, .topRight):   return [t, b, r]
        case (.northWest, .botLeft):    return [b, l, r]
        case (.northWest, .botRight):   return [t, b, l, r]

        // └
        case (.northEast, .topLeft):    return [t, b, l]
        case (.northEast, .topRight):   return [t, r]
        case (.northEast, .botLeft):    return [t, b, l, r]
        case (.northEast, .botRight):   return [b, l, r]

        // ┐
        case (.southWest, .topLeft):    return [t, l, r]
        case (.southWest, .topRight):   return [t, b, l, r]
        case (.southWest, .botLeft):    return [b, l]
        case (.southWest, .botRight):   return [t, b, r]

        // ┌
        case (.southEast, .topLeft):    return [t, b, l, r]
        case (.southEast, .topRight):   return [t, l, r]
        case (.southEast, .botLeft):    return [t, b, l]
        case (.southEast, .botRight):   return [b, r]

        case (.start, _):        fatalError()
        }
    }

    func adjx(pos: Pos) -> [Pos] {
        deltax(subtype: Self.posSubtype(pos)).map { $0 + pos }
    }


    var debugCh: Character {
        switch self {
        case .empty: return "·"
        case .vertical: return "│"
        case .horizontal: return "─"
        case .northWest: return "┘"
        case .northEast: return "└"
        case .southWest: return "┐"
        case .southEast: return "┌"
        case .start: return "S"
        }
    }
}

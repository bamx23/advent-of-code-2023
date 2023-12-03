//
//  Day03.swift
//  AdventOfCode2023
//
//  Created by Nikolay Volosatov on 03/12/2023.
//

import Foundation
import Shared

public struct Day03: Day {
    static public let number = 3

    let input: String

    enum Cell {
        case digit(Int)
        case symbol(Character)
    }

    public init(input: String) {
        self.input = input
    }

    func parse() -> [[Cell?]] {
        input
            .split(separator: "\n")
            .map { line in
                line.map { ch in
                    if ch.isWholeNumber {
                        return .digit(ch.wholeNumberValue!)
                    }
                    if ch == "." {
                        return nil
                    }
                    return .symbol(ch)
                }
            }
    }

    public func part01() -> String {
        let map = parse()
        let (h, w) = (map.count, map.first!.count)

        var values = [Int]()
        var visited = [[Bool]](repeating: [Bool](repeating: false, count: w), count: h)
        for y in 0..<h {
            for x in 0..<w {
                if case .symbol = map[y][x] {
                    for dy in -1...1 {
                        for dx in -1...1 {
                            if dx == 0 && dy == 0 { continue }
                            let (ny, nx) = (y + dy, x + dx)
                            if ny < 0 || nx < 0 || ny >= h || nx >= w { continue }
                            if case .digit = map[ny][nx], visited[ny][nx] == false {
                                var (l, r) = (nx, nx)
                                while l >= 0, case .digit = map[ny][l] { l -= 1 }
                                while r < h, case .digit = map[ny][r] { r += 1 }
                                var value = 0
                                for cx in (l + 1)..<r {
                                    guard case let .digit(dig) = map[ny][cx] else { fatalError() }
                                    visited[ny][cx] = true
                                    value = value * 10 + dig
                                }
                                values.append(value)
                            }
                        }
                    }
                }
            }
        }
        return "\(values.reduce(0, +))"
    }

    public func part02() -> String {
        let map = parse()
        let (h, w) = (map.count, map.first!.count)

        var gearRatios = [Int]()
        for y in 0..<h {
            for x in 0..<w {
                if case .symbol("*") = map[y][x] {
                    var values = [Int]()
                    var visited = [[Bool]](repeating: [Bool](repeating: false, count: 3), count: 3)
                    for dy in -1...1 {
                        for dx in -1...1 {
                            if dx == 0 && dy == 0 { continue }
                            let (ny, nx) = (y + dy, x + dx)
                            if ny < 0 || nx < 0 || ny >= h || nx >= w { continue }
                            if case .digit = map[ny][nx], visited[dy + 1][dx + 1] == false {
                                var (l, r) = (nx, nx)
                                while l >= 0, case .digit = map[ny][l] { l -= 1 }
                                while r < h, case .digit = map[ny][r] { r += 1 }
                                var value = 0
                                for cx in (l + 1)..<r {
                                    guard case let .digit(dig) = map[ny][cx] else { fatalError() }
                                    if abs(cx - nx) <= 1 { visited[dy + 1][cx - nx + 1] = true }
                                    value = value * 10 + dig
                                }
                                values.append(value)
                            }
                        }
                    }
                    if values.count == 2 { gearRatios.append(values.reduce(1, *)) }
                }
            }
        }
        return "\(gearRatios.reduce(0, +))"
    }
}

//
//  Day11.swift
//  AdventOfCode2023
//
//  Created by Nikolay Volosatov on 11/12/2023.
//

import Foundation
import Algorithms
import Shared

public struct Day11: Day {
    static public let number = 11

    let input: String

    public init(input: String) {
        self.input = input
    }

    func parse() -> [[Bool]] {
        input
            .split(separator: "\n")
            .map { l in l.map { $0 == "#" } }
    }

    private func dist(_ v1: Int, _ v2: Int, _ exps: [Int], _ expFactor: Int) -> Int {
        guard v1 != v2 else { return 0 }
        let (v1, v2) = v1 < v2 ? (v1, v2) : (v2, v1)
        var expansions = 0
        if let firstExp = exps.firstIndex(where: { $0 > v1 && $0 < v2 }) {
            let lastExp = exps.lastIndex(where: { $0 > v1 && $0 < v2 })!
            expansions = (lastExp - firstExp + 1) * expFactor
        }
        return v2 - v1 + expansions
    }

    private func solve(expFactor: Int = 1) -> Int {
        let field = parse()
        let emptyRows = field.enumerated()
            .filter({ (_, r) in r.allSatisfy { $0 == false } })
            .map(\.offset)
        let emptyCols = field
            .reduce(into: [Bool](repeating: true, count: field.count), { (result, row) in
                for (idx, val) in row.enumerated() { result[idx] = result[idx] && (val == false) }
            })
            .enumerated().filter { $1 }.map(\.offset)
        let galaxies = field.enumerated()
            .flatMap { (y, row) -> [Pos] in
                row.enumerated().compactMap { (x, val) -> Pos? in
                    guard val else { return nil }
                    return Pos(x: x, y: y)
                }
            }
        let result = galaxies.combinations(ofCount: 2)
            .map { pair -> Int in
                let (a, b) = (pair.first!, pair.last!)
                return dist(a.x, b.x, emptyCols, expFactor)
                    + dist(a.y, b.y, emptyRows, expFactor)
            }
            .reduce(0, +)
        return result
    }

    public func part01() -> String {
        return "\(solve())"
    }

    public func part02() -> String {
        return "\(solve(expFactor: 999_999))"
    }
}

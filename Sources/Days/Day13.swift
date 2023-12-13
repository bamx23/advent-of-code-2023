//
//  Day13.swift
//  AdventOfCode2023
//
//  Created by Nikolay Volosatov on 13/12/2023.
//

import Foundation
import Algorithms
import Shared

public struct Day13: Day {
    static public let number = 13

    let input: String

    public init(input: String) {
        self.input = input
    }

    func parse() -> [[[Bool]]] {
        input
            .split(separator: "\n\n")
            .map { block in
                block.split(separator: "\n").map { line in
                    line.map { $0 == "#" }
                }
            }
    }

    private static func diff<T: Equatable>(_ m: Int, _ line: [T]) -> Int {
        var count = 0
        for idx in 0..<min(m, line.count - m) {
            if line[m - idx - 1] != line[m + idx] {
                count += 1
                if count == 2 { break } // We don't need more detailed diffs
            }
        }
        return count
    }

    private func mirrorCols(_ map: [[Bool]], _ isFixNeeded: Bool = false) -> Int? {
        func check(_ m: Int, _ fromLine: Int, _ allowFix: Bool) -> Bool {
            for lIdx in fromLine..<map.count {
                switch Self.diff(m, map[lIdx]) {
                case 0: break
                case 1: return allowFix ? check(m, lIdx + 1, false) : false
                default: return false
                }
            }
            return allowFix == false // allowFix needs to be false by here
        }

        let mirrors = map.first!.indices.dropFirst()
            .filter { check($0, 0, isFixNeeded) }
        return mirrors.count == 1 ? mirrors.first! : nil
    }

    public func part01() -> String {
        let result = parse()
            .compactMap { map in mirrorCols(map) ?? mirrorCols(map.transpose()).map { $0 * 100 } }
            .reduce(0, +)
        return "\(result)"
    }

    public func part02() -> String {
        let result = parse()
            .compactMap { map in mirrorCols(map, true) ?? mirrorCols(map.transpose(), true).map { $0 * 100 } }
            .reduce(0, +)
        return "\(result)"
    }
}

private extension Array where Element == Array<Bool> {
    func transpose() -> Self {
        guard count != 0 else { return [] }
        let (h, w) = (count, first!.count)
        var result = Self(repeating: [Bool](repeating: false, count: h), count: w)
        for y in 0..<h {
            for x in 0..<w {
                result[x][y] = self[y][x]
            }
        }
        return result
    }
}

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

    private func mirrorCols(_ map: [[Bool]]) -> Int? {
        var mirrors = Set(map.first!.indices.dropFirst())
        for line in map {
            var nextMirrors = mirrors
            for m in mirrors {
                for idx in 0..<m {
                    let (a, b) = (m - idx - 1, m + idx)
                    guard line.indices.contains(a) && line.indices.contains(b) else { continue }
                    if line[a] != line[b] {
                        nextMirrors.remove(m)
                        break
                    }
                }
            }
            mirrors = nextMirrors
        }
        guard mirrors.count == 1 else { return nil }
        return mirrors.first!
    }

    private func mirrorExCols(_ map: [[Bool]]) -> Int? {

        func diff(_ m: Int, _ lineIdx: Int) -> Int {
            var count = 0
            for idx in 0..<m {
                let (a, b) = (m - idx - 1, m + idx)
                guard map[lineIdx].indices.contains(a) && map[lineIdx].indices.contains(b) else { continue }
                if map[lineIdx][a] != map[lineIdx][b] {
                    count += 1
                    if count == 2 { break } // We don't need more detailed diffs
                }
            }
            return count
        }

        func check(_ m: Int, _ fromLine: Int, _ allowFix: Bool) -> Bool {
            for lIdx in fromLine..<map.count {
                switch diff(m, lIdx) {
                case 0: 
                    break
                case 1:
                    return allowFix ? check(m, lIdx + 1, false) : false
                default:
                    return false
                }
            }
            return allowFix == false // allowFix needs to be false by here
        }

        let mirrors = map.first!.indices.dropFirst()
            .filter { check($0, 0, true) }
        guard mirrors.count == 1 else { return nil }
        return mirrors.first!
    }

    public func part01() -> String {
        let result = parse()
            .compactMap { map in mirrorCols(map) ?? mirrorCols(map.transpose()).map { $0 * 100 } }
            .reduce(0, +)
        return "\(result)"
    }

    public func part02() -> String {
        let result = parse()
            .compactMap { map in mirrorExCols(map) ?? mirrorExCols(map.transpose()).map { $0 * 100 } }
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
